% % ************************************************************************
% % Author:     Justin A Brantley
% % Date:       11/01/2019
% % Comments:   Kernel Ridge Regression w/Gaussian kernel (RBF)
% % ToDo:       Improve paramters search from grid search. 
% % ************************************************************************
% 
% % Usage: I used it in my research to predict movement from EEG recordings. 
% % The code should be adaptable to any other data types (assuming correct 
% % input matrices), but this functionality not been tested. 
% % 
% % Data: Note that the matrices are number of channels (e.g., number of EEG
% % channels for observation and number of motion sensors x time for state) by 
% % time. They will eventually be transposed so that each channel is a column 
% % and each row is a time point (more MATLAB efficient). This was just done 
% % due to some ways in which the data are streamed in real time and offline. 
% % Note that if you want to lag the data, you can see
% % KalmanFilter.lag_data() to do this.
% state_train       = [number of channels x time]
% state_test        = [number of channels x time]
% observation_train = [number of channels x time] 
% observation_test  = [number of channels x time] 
% 
% 
% % KRR parameters: These params can either be a vector of values
% % or single scalar values. They are used in the nested for loop in the grid
% % search. See .Optimize() for the nested loops.
% SIGMA  = [.1 1 10]; % vector/scalar of sigma values in RBF
% LAMBDA = [.1 1 10]; % vector/scalar ridge param
% 
% % Number of folds:  scalar or you can also pass in a set of indices 
% % marking the boundary for each fold if you dont want it symmetric 
% % e.g., [1, 300, 600, ....]. 
% % NOTE: if folds=1 and sigma=scalar and lambda=scalar then it does not 
% % perform grid search by default. If sigma and lambda are vectors then the
% % folds are automatically changed to 5. 
% FOLDS = 10; % <-- Fold boundaries are calculated for equal size bins
% 
% % Kernel Ridge Regression object
% KRR = KernelRidgeRegression(observation_train, state_test,...
%                             SIGMA, LAMBDA, FOLDS);
% 
% % Perform grid search or just train for all scalar params
% KRR.Train()
% 
% % Predict on new data
% predicted = KRR.Predict(observation_test);
% 
% % Compute R2 value. You can also compute the pearson correlation using
% % KalmanFilter.PearsonCorr(predicted,state_test)
% R2 = KRR.R2(predicted,state_test);

classdef KernelRidgeRegression < hgsetget
    % Used to perform kernel ridge regression with Gaussian kernel
    properties (SetAccess = public, GetAccess = public)
        % Store kernel
        % kernel
        % Store Trained model
        model
        % Store training data
        predictor
        % Store predicted variable
        response
        % Store parameters
        sigma
        lambda
        
    end
    
    methods (Access = public)
        %Constructer
        function self = KernelRidgeRegression(predictor,response,sigma,lambda)
            % Assign inputs to class
            self.predictor = predictor;
            self.response  = response;
            % Sigma and lambda can be scalar or vector. If vector, use
            % optimize method. This will assign optimal values to sigma and
            % lambda properties
            self.sigma  = sigma;
            self.lambda = lambda;
            self.folds  = 1; % Scalar or vector of fold boundaries. 
                             % If fold_idx = 1 it does not perform a
                             % grid search across folds. If sigma or lambda
                             % are > 1 then it will automatically make the
                             % folds = 2. Check .Train()
        end
        
        % Train Kernel Ridge Regression Model
        function Train(self)
            if (length(self.sigma) > 1) || (length(self.lambda > 1)
                if self.folds == 1
                    self.folds = 5;
                end
                self.Optimize()
            else
                % Computer kernel
                K = self.ComputeKernel(self.predictor',self.predictor',self.sigma);
                % Ridge regression
                RegularizationMatrix= eye(size(K,1));
                self.model = ((K+self.lambda*RegularizationMatrix)^-1)*self.response;
            end
        end
        
        % Predict output
        function predicted = Predict(self,test)
            % Assign variables - make row vector
            test = test(:); % test
            % Computer kernel with test data
            K = self.ComputeKernel(self.predictor',test',self.sigma);
            % Predict
            predicted = K'*self.model;
        end
        
        % Kernel Ridge Regression optimization function
        function [cost_final, predict_final, R2] = Optimize(self)
            % ASSUMES VECTORS NOT SCALARS ARE ASSIGNED TO SIGMA AND
            % LAMBDA IN CONSTRUCTOR
            sigma_vec  = self.sigma;
            lambda_vec = self.lambda;
            fold_idx   = self.folds;
            
            % Store original train data
            predictor_data = self.predictor;
            response_data  = self.response;
            
            % Get folds
            allfolds = cell(size(fold_idx,1),1);
            for ii = 1:size(fold_idx,1)
                allfolds{ii} = fold_idx(ii,1):fold_idx(ii,2);
            end
            
            % Store all R2 for reference
            R2 = zeros(length(sigma_vec),length(lambda_vec));
            % Create temp variables
            predict_final = []; cost_final = 0; model_final = [];
            sigma_final = []; lambda_final = [];
            % Loop over parameters
            for ii = 1:length(sigma_vec)
                for jj = 1:length(lambda_vec)
                    % Assign values to class
                    self.sigma  = sigma_vec(ii);
                    self.lambda = lambda_vec(jj);
                    R2_temp = zeros(size(fold_idx,1),1);
                    predict_temp = cell(size(fold_idx,1),1);
                    mdl_temp = cell(size(fold_idx,1),1);
                    for kk = 1:size(fold_idx,1)
                        % Get folds
                        trainfolds = setxor(1:size(fold_idx,1),kk);
                        testfolds  = kk;
                        % Assign variables - make column vector
                        self.predictor = predictor_data([allfolds{trainfolds}],:); % Train data - predictor (emg)
                        self.response = response_data([allfolds{trainfolds}],:); % Train data - response (angle)
                        X2 = predictor_data([allfolds{testfolds}],:);  % Test data  - predictor (emg)
                        Y2 = response_data([allfolds{testfolds}],:);  % Test data  - response (angle)
                        % Train model - run kernel ridge regression
                        self.Train;
                        mdl_temp{kk} = self.model;
                        % Predict values and compute cost
                        predict_temp{kk} = self.Predict(X2);
                        R2_temp(kk)    = self.Cost(predict_temp,Y2);
                    end
                    [~, locMaxR2] = med(R2_temp);
                    R2(ii,jj) = med(R2_temp);
                    if med(R2_temp) > cost_final
                        cost_final    = cost_temp;
                        model_final   = mdl_temp(locMaxR2);
                        predict_final = predict_temp{locMaxR2};
                        sigma_final   = sigma_vec(ii);
                        lambda_final  = lambda_vec(jj);
                    end
                end
            end
            % assign optimal values to class
            self.model  = model_final;
            self.sigma  = sigma_final;
            self.lambda = lambda_final;
        end % end KRR_Optimize
        
    end
    % Static methods - do not rely on class
    methods (Static)
        % Compute Kernel Matrix
        function K = ComputeKernel(in1,in2,sigma)
            % Input is instances (rows) by features (columns)
            n1sq = sum(in1.^2,1);
            n1 = length(in1);
            n2sq = sum(in2.^2,1);
            n2 = length(in2);
            % Compute Kernel with train data
            D = (ones(n2,1)*n1sq)' + ones(n1,1)*n2sq -2*(in1'*in2);
            K = exp(-D/2*sigma^2);
        end
        
        % Compute cost: 1-R^2 where 0 < R^2 < 1
        function cost = R2(predicted,actual)
            SSE = sum((actual-predicted).^2);
            SST = sum((actual - mean(actual)).^2);
            cost = max(0,1-SSE/SST);
        end
        
    end
    
end % end classdef

