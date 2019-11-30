classdef KalmanFilter < handle
    properties (SetAccess = private, GetAccess = public)
        %%% UNIVERSAL PROPERTIES %%%
        F          % State transition matrix
        Q          % State covariance
        B          % Neural tuning model
        R          % Neural tuning model covariance
        Xt         % Actual state
        Pt         % Actual state covariance
        Xtp        % Predicted state
        Ptp        % Predicted covariance
        z          % Predicted observation (e.g., neural data)
        KGain      % Kalman gain
        
        %%% KF PROPERTIES %%%
        St      % Covariance matrix for predicted observation
        
        %%% UKF PROPERTIES %%%
        Pzz     % Covariance of predicted observation (neural data)
        Pxz     % State-observation cross-covariance
        
        %%% Store data properties %%%
        mu          % Mean data
        sigma       % Standard deviation of data
        standardize % Standardize data
        
        % Pearsons correlation (R1) and R2 value after performing grid search
        R1_Train
        R1_GridSearch
        R2_Train
        R2_GridSearch
        
    end
    properties (SetAccess = public, GetAccess = public)
        state       = [];        % e.g., kin - channels x time
        lags        = [];        % lagged observation datas
        observation = [];        % e.g., eeg, emg - channels x time
        order       = 1;         % Kalman filter order - num state lags
        lambdaF     = 1;         % For deriving state transition matrix
        lambdaB     = 1;         % For deriving neural tuning model
        futuretaps  = 0;         % Number of future taps
        method      = 'normal';  % {'normal','unscented'}
        sigmamethod = 'normal';  % Method to obtain sigma points: 'normal', 'svd'
        augmented   = 'false';   % Method for state augmentation
        numaug      = 1;         % Determines how many values to use for augment
        % (e.g., numaug = 2: [posx(t) posy(t) posaug(t) ...
        % velx(t) vely(t) velaug(t) posx(t-1) posy(t-1) posaug(t-1) ...
    end
    methods (Access = public) %Constructor
        %Constructor
        function self = KalmanFilter(varargin)
            % Parse inputs
            if length(varargin)>=2
                for i=1:2:length(varargin)
                    param=varargin{i};
                    val=varargin{i+1};
                    switch lower(param)
                        case 'order'
                            self.order=val;
                        case 'lags'
                            self.lags=val;
                        case 'state'
                            self.state=val;
                        case 'observation'
                            self.observation=val;
                        case 'lambdaf'
                            self.lambdaF=val;
                        case 'lambdab'
                            self.lambdaB=val;
                        case 'sigmamethod'
                            self.sigmamethod=val;
                        case 'augmented'
                            self.augmented=val;
                        case 'numaug'
                            self.numaug=val;
                        case 'futuretaps'
                            self.futuretaps=val;
                        case 'method'
                            self.method=val;
                        case 'mean'
                            self.mu=val;
                        case 'std'
                            self.sigma=val;
                        otherwise
                    end
                end
            end
        end
    end
    % Public methods
    methods (Access = public)
        % Train Kalman Filter by estimating state and observation matrices
        function train(self)
            X = self.state;        % State variable: (e.g., kin)
            N = self.order;        % Filter order
            % Get size of X
            [m, T] = size(X);
            % Get dimension after order
            d = size(self.state,1)*self.order;
            % Generate state model
            [Xcut, Xlag] = self.state_model();
            % Generate observation model (e.g., emg, eeg)
            [Y, Xaug] = self.observation_model();
            % Perform ridge regression to compute state transition matrix
            Fpart = Xcut*Xlag' / ( Xlag*Xlag' + self.lambdaF*eye(d));
            self.F = [Fpart; [eye(d-m) zeros(d-m, m)]];
            % Compute residuals from fitting F
            Ef = Xcut - Fpart*Xlag;
            % Construct estimated movement model noise covariance matrix
            Qpart = Ef*Ef' ./ (T-N - d);
            self.Q = [[Qpart zeros(m, d-m)]; zeros(d-m, d)];
            % Perform ridge regression to compute linear tuning model
            self.B = Y*Xaug' / (Xaug*Xaug' + self.lambdaB*eye(size(Xaug,1)));
            % Compute residuals from fitting B (H in Li et al)
            Eb = Y - self.B*Xaug;
            % Compute estimated neural tuning model covariance matrix
            self.R = Eb*Eb' ./ (T-N+1 - size(Xaug,1));
            % Initialize matrices
            self.Xt  = zeros(d,1);
            self.Xtp = zeros(d,1);
            self.Pt  = eye(d);
        end % end train
        
        % Predict using trained Kalman Filter model
        function Xt_out = predict(self,Y) % X is state, Y is observe
            Xt_1 = self.Xt;           % X(t-1) - past X values
            Yt   = Y;                 % Y(t)   - current Y value
            N    = self.order;        % Filter order
            % Get dimension after order
            d = size(self.state,1)*N;
            %%%%%%%%%%%%%%%%%%%%%%%%%
            %                       %
            %        PREDICT        %
            %                       %
            %%%%%%%%%%%%%%%%%%%%%%%%%
            self.Xtp = self.F*Xt_1;
            self.Ptp = self.F*self.Pt*self.F' + self.Q;
            %%%%%%%%%%%%%%%%%%%%%%%%%
            %                       %
            %        UPDATE         %
            %                       %
            %%%%%%%%%%%%%%%%%%%%%%%%%
            % Perform unscented transform for UKF
            if strcmpi(self.method,'unscented')
                % Initialize unscented data matrix
                sigmapoints = zeros(d, 2*d+1);
                % Perform unscented transform
                sqrtP = real(sqrtm((d+1)*self.Ptp));
                [~,warnID] = lastwarn;
                if ~isempty(warnID) && strcmpi(warnID,'MATLAB:sqrtm:SingularMatrix')
                    %disp(warnID);
                    lastwarn('');
                    sqrtP = real(sqrtm(self.Ptp+.01.*randn(size(self.Ptp))));
                end
                    % ------------------------------- %
                    %                                 %
                    %     Regular Kalman Filter       %
                    %                                 %
                    % ------------------------------- %
                    % Augment state
%                     self.Xtp = self.augment_state(self.Xtp);
%                     % Compute predicted obsevation (e.g., neural firing rates)
%                     self.z = self.B*self.Xtp;
%                     % Update covariance matrix for predicted observation
%                     self.St = self.B*self.Ptp*self.B' + self.R;
%                     % Update Kalman gain
%                     self.KGain = self.Ptp*self.B'/self.St;
%                     % Correct state estimate using error between predicted and
%                     % actual observation
%                     self.Xt = self.Xtp + self.KGain*(Yt - self.z);
%                     % Update state covariance
%                     self.Pt = (eye(d) - self.KGain*self.B)*self.Ptp;
                      % Luu's methodself.Pt = self.Q
                %else
                    sigmapoints(:,         1) = self.Xtp;
                    sigmapoints(:,   2:  d+1) = repmat(sigmapoints(:,1), 1, d) + sqrtP;
                    sigmapoints(:, d+2:2*d+1) = repmat(sigmapoints(:,1), 1, d) - sqrtP;
                    % Augment unscented data
                    sigmapoints_aug = self.augment_state(sigmapoints);
                    % Compute predicted observation after unscented transform
                    % and augmentation
                    Z = zeros(size(self.B,1),2*d+1);
                    for ii = 1:2*d+1
                        Z(:,ii) = self.B*sigmapoints_aug(:,ii);
                    end
                    % Compute mean of predicted observation (neural data)
                    w = ones(1, 2*d+1)*1/(2*(d+1)); % w_i = 1/2(d+Kappa); Kappa = 1
                    w(1) = 1/(d+1);                 % w_0 = Kappa/d+Kappa where Kappa = 1
                    self.z = Z*w';                  % z_t = sum_0:2d(w_i*Z_i)
                    % Compute covariance of predicted observation (neural data)
                    self.Pzz = w(1) * (Z(:,1) - self.z) * (Z(:,1) - self.z)' + self.R;
                    for ii = 2:2*d+1
                        self.Pzz = self.Pzz + ( w(ii) * (Z(:,ii)-Z(:,1)) * (Z(:,ii)-Z(:,1))' );
                    end
                    % Compute state-observation cross-covariance
                    self.Pxz = w(1) * (sigmapoints(:,1) - self.Xtp) * (Z(:,1) - self.z)';
                    for ii = 2:2*d+1
                        self.Pxz = self.Pxz + ( w(ii) * (sigmapoints(:,ii)-sigmapoints(:,1)) * (Z(:,ii)-Z(:,1))' );
                    end
                    % Update kalman gain
                    self.KGain = self.Pxz*pinv(self.Pzz);
                    % Correct state estimate using error between predicted and
                    % actual observation
                    self.Xt = self.Xtp + self.KGain*(Yt - self.z);
                    % Update state covariance
                    self.Pt = self.Ptp - self.Pxz*(pinv(self.Pzz))'*self.Pxz';
                %end
            else % normal Kalman filter
                % Augment state
                self.Xtp = self.augment_state(self.Xtp);
                % Compute predicted obsevation (e.g., neural firing rates)
                self.z = self.B*self.Xtp;
                % Update covariance matrix for predicted observation
                self.St = self.B*self.Ptp*self.B' + self.R;
                % Update Kalman gain
                self.KGain = self.Ptp*self.B'*pinv(self.St);
                % Correct state estimate using error between predicted and
                % actual observation
                self.Xt = self.Xtp + self.KGain*(Yt - self.z);
                % Update state covariance
                self.Pt = (eye(d) - self.KGain*self.B)*self.Ptp;
            end % end if
            Xt_out = self.Xt; % return predicted state
            
        end % end predict
        
        % Evaluate model using training data
        function prediction = evaluate(self,observedata)
            T = size(observedata,2);
            % Preallocate
            prediction = zeros(size(self.Xt,1),T);
            % Initialize prediction
            KF_Out = zeros(size(self.Xt));
            for ii = 1:T
                % Get lagged state data
                paststate = KF_Out; %test_ang(:,ii);%fliplr(test_ang_cut(:,ii-KF.order:ii-1));
                % Get current observation
                currentobs = observedata(:,ii);
                % Predict new data
                %KF_Out = self.predict(paststate,currentobs);
                KF_Out = self.predict(currentobs);
                % Store predicted value
                prediction(:,ii) = KF_Out;
            end
        end
        
        % Generate state model
        function [Xcut, Xlag] = state_model(self)
            X = self.state;        % State variable: (e.g., kin)
            N = self.order;        % Filter order
            % Generate lagged state matrix
            Xlagged = self.lag_data(X,N);
            % Trim X and Xlag to same size
            Xcut = X(:, N+1:end);
            Xlag = Xlagged(:, N+1:end);
        end % end state_model
        
        % Generate observation model
        function [Ycut, Xaug] = observation_model(self)
            X = self.state;        % State variable: (e.g., kin)
            Y = self.observation;  % Observation: (e.g., emg, eeg) transposed to time x channels
            N = self.order;        % Filter order
            L = self.lags;         % Observation lag
            K = self.futuretaps;   % Number of future taps
            % Generate lagged state matrix
            Xlagged = KalmanFilter.lag_data(X,N);
            Ylagged = KalmanFilter.lag_data(Y,L);
            % Augment data
            Xaugmented = self.augment_state(Xlagged);
            % Shift for future taps - do nothing if K = 0
            Ylag = Ylagged(:, 1:end-K);
            Xlag = Xaugmented(:, 1+K:end);
            % Trim Xaug and Y to same size
            maxval = max([N,L]);
            Ycut   = Ylag(:, maxval+1-K:end);
            Xaug   = Xlag(:, maxval+1-K:end);
        end % end observation_model
        
        % Compute augmented state
        function Xaug = augment_state(self,Xlag)
            % If UKF and augmented==true
            if self.augmented && strcmpi(self.method,'unscented') % {'true',1}
                Xaug = KalmanFilter.augment_data(Xlag,self.numaug);
            else% {'false',0}
                % do nothing
                Xaug = Xlag;
            end
        end % end augment
        
        % Optimize model
        function self = grid_search(self,varargin)
            params = struct;
            for numfolds=1:2:length(varargin)
                param=varargin{numfolds};
                val=varargin{numfolds+1};
                switch lower(param)
                    case 'order' % vector/scalar of state order
                        params.order=val;
                    case 'lags'  % vector/scalar of observation lags
                        params.lags=val;
                    case 'lambdaf' % vector/scalar ridge param for F
                        params.lambdaF=val;
                    case 'lambdab' % vector/scalar ridge param for B
                        params.lambdaB=val;
                    case 'kfold' % vector of fold sizes or number of folds (scalar)
                        if length(val) > 1 % already length of each fold
                            params.kfold=val;
                        else % get length of each fold window
                            params.kfold=round(linspace(1,size(self.state,2),val+1));
                        end
                    case 'augmented'
                        params.augmented=val;
                    case 'method'
                        params.method=val;
                    case 'testidx'
                        params.testidx=val;
                    otherwise
                end
            end
            % Save data for later - will be changed each loop
            state_orig   = self.state;
            observe_orig = self.observation;
            % Initialize array for storing R2 values
            allR1 = zeros(length(params.lags),length(params.order),length(params.lambdaF),length(params.lambdaB));
            allR1_ALL = cell(length(params.lags),length(params.order),length(params.lambdaF),length(params.lambdaB));
            allR2 = zeros(length(params.lags),length(params.order),length(params.lambdaF),length(params.lambdaB));
            allR2_ALL = cell(length(params.lags),length(params.order),length(params.lambdaF),length(params.lambdaB));
            % Create folds if not specified
            if ~isfield(params,'kfold')
                params.kfold=round(linspace(1,size(self.state,2),3));
            end
            % Get total number of iterations
            totalIterations = (numel(allR2)*(length(params.kfold)-1))+1; % +1 accounts for where counter is in loop
            fprintf('Total number of iterations: %d\n\n',totalIterations)
            pause(.1);
            wb = waitbar(0,'Training Kalman Filter model...');
            cnt = 1;
            % Separate data into folds
            state_folds    = cell(1,length(params.kfold)-1);
            observe_folds  = cell(1,length(params.kfold)-1);
            % Get fold breaks
            foldIdx = params.kfold;
            for numfolds = 1:length(foldIdx)-1
                state_folds{numfolds}  = state_orig(:,foldIdx(numfolds):foldIdx(numfolds+1)-1);
                observe_folds{numfolds} = observe_orig(:,foldIdx(numfolds):foldIdx(numfolds+1)-1);
            end
            % Begin grid search
            for aa = 1:length(params.lags) % observation lags
                lag = params.lags(aa);
                % Loop through each order
                for bb = 1:length(params.order) % state order
                    ord = params.order(bb);
                    % Loop through each lambda F
                    for cc = 1:length(params.lambdaF) % ridge param for F
                        lamF = params.lambdaF(cc);
                        % Loop through each lambda B
                        for dd = 1:length(params.lambdaB) % ridge param for B
                            lamB = params.lambdaB(dd);
                            % Loop through each fold
                            R2 = zeros(1,length(params.kfold)-1);
                            R1 = zeros(1,length(params.kfold)-1);
                            for ee = 1:length(params.kfold)-1 % k folds
                                % Get test data
                                test_state   = state_folds{ee};
                                test_observe = observe_folds{ee};
                                % Get training data
                                train_state       = cat(2,state_folds{setxor(1:length(params.kfold)-1,ee)});
                                train_observe     = cat(2,observe_folds{setxor(1:length(params.kfold)-1,ee)});
                                % Update kalman filter object
                                self.state       = train_state;   % update state
                                self.observation = train_observe; % update observation
                                self.lags        = lag;
                                self.order       = ord;           % update filter order (state)
                                self.lambdaF     = lamF;          % update F ridge param
                                self.lambdaB     = lamB;          % update B ridge param
                                % Train filter
                                self.train();
                                % Preallocate
                                prediction = zeros(1,size(test_state,2));
                                % Initialize prediction
                                KF_Out = zeros(size(train_state,1)*self.order,1);
                                % Test filter
                                for ff = self.lags+1:size(test_state,2)
                                    % Get lagged state data
                                    paststate = KF_Out; %fliplr(test_state(:,ff-ord:ff-1));
                                    % Get current observation
                                    currentobs  = fliplr(test_observe(:,ff-lag+1:ff));
                                    % Predict new data
                                    KF_Out = self.predict(currentobs(:));
                                    % Predicted value
                                    prediction(ff) = KF_Out(1);
                                end
                                % Compute R2 value
                                R2(ee) = KalmanFilter.rsquared(zscore(prediction(params.testidx,ord+1:end)),zscore(test_state(params.testidx,ord+1:end)));
                                R1(ee) = KalmanFilter.PearsonCorr(zscore(prediction(params.testidx,ord+1:end)),zscore(test_state(params.testidx,ord+1:end)));
                                % Update count
                                cnt = cnt+1;
                                waitbar(cnt/totalIterations,wb);
                            end
                            % Compute mean r squared
                            allR1(aa,bb,cc,dd)= mean(R1);
                            allR1_ALL{aa,bb,cc,dd}= R1;
                            allR2(aa,bb,cc,dd)= mean(R2);
                            allR2_ALL{aa,bb,cc,dd}= R2;
                        end % lambda B
                    end % lambda F
                end % order
            end % lag
            waitbar(1,wb,'Finished!');
            pause(1); delete(wb); pause(1);
            % Plot distribution of R2
            %             try
            %                 figure; histfig = histogram(allR2(:));
            %                 histfig.FaceColor = 'k';
            %                 histfig.NumBins = 10;
            %             catch err
            %                 % do nothing
            %             end
            % Get index of max
            [idx1, idx2, idx3, idx4] = ind2sub(size(allR2), find(allR2==max(allR2(:))));
            % Add values to struct - idx*(1) is chosen in case multiple
            % param combos result in equal R2
            self.lags        = params.lags(idx1(1));
            self.order       = params.order(idx2(1));
            self.lambdaF     = params.lambdaF(idx3(1));
            self.lambdaB     = params.lambdaB(idx4(1));
            self.state       = state_orig;
            self.observation = observe_orig;
            self.R1_Train    = max(allR1(:));
            self.R1_GridSearch = allR1_ALL;
            self.R2_Train    = max(allR2(:));
            self.R2_GridSearch = allR2_ALL;
            % Train model using updated params
            self.train();
        end
    end % end (Access = Public)
    
    % Static methods
    methods (Static)
        function r = PearsonCorr(x,y)
            % Calculate the Pearson correlation coefficient between vectors x and y
            x = x(:);
            y = y(:);
            % Get size of data
            [n,~] = size(x);
            [m,~] = size(y);
            % Compute r value
            if n == m
                mu_x = mean(x);
                mu_y = mean(y);
                % Get num
                num = (x - mu_x)' * (y - mu_y);
                % Get denom
                denom = sqrt(sum((x - mu_x).^2)) * sqrt(sum((y - mu_y).^2));
                % Compute r-value
                r = num/denom;
            else
                error('X and Y must be the same length.')
            end
        end
        % Compute R Squared value
        function R2 = rsquared(predicted,actual)
            R2 = zeros(size(actual,1),1);
            for ii = 1:size(actual,1)
                % Get data
                X = actual(ii,:);
                Y = predicted(ii,:);
                % Compute R2
                SSE  = sum((X-Y).^2);   % Sum of squared error
                SST  = sum((X-mean(X)).^2); % Sum of squared total
                R2(ii) = 1-SSE/SST;%max(0,1-SSE/SST);             % R squared
            end
        end %end rsquared
        
        % Generate lagged data
        function Xlagged = lag_data(X,numlags)
            % Get size of X
            [m, T] = size(X);
            % Get dimension after order (lags)
            d = m*numlags;
            % Generate lagged matrix
            Xlagged = zeros(d,T);
            for ii = 1:numlags
                Xlagged((ii-1)*m+1:ii*m, ii+1:end) = X(:, 1:T-ii);
            end
        end % end lag
        
        % Augment data - this static implementation can be used to augment
        % state variable for use in state and observation matrices
        function Xaug = augment_data(Xin,numaug)
            % Get dimension after order
            d = size(Xin,1);
            % Initialize augmented matrix
            XaugTemp = cell(d/numaug,1);
            cnt = 1;
            for ii = 1:numaug:d
                xtemp = Xin(ii:ii+numaug-1,:);
                augvec = sqrt(sum(xtemp.^2,1));
                XaugTemp{cnt} = [xtemp; augvec];
                cnt = cnt+1;
            end
            % Concatenate
            Xaug = cat(1,XaugTemp{:});
        end % end augment
        
    end % end (Static)
    
    methods (Access = private) %Destructor
        %         function delete(self)
        %             fprintf('Delete Kalman Filter object. \n');
        %             delete(self);
        %         end
    end
end

