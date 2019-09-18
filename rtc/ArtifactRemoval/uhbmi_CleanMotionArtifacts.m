function outData = uhbmi_CleanMotionArtifacts(inDataEEG, inDataRef, gamma, q, numTaps, A, B, C, D)

%#codegen

% This code is based on "VHINF_v004.m"

%% Persistent Variables

persistent isFirstLoop XnnBPFilter refBuffer PtHinf whHinf cleanData REF isLinear



%% initializations

% From Input
numRefChannels  = size(inDataRef,2);
numDecomp       = size(A,3);
butterOrder     = size(A,1)/2;
numDataChannels = size(inDataEEG,2);
numTimePoints   = size(inDataRef,1);

% Other
if numTaps>1
    numHinfRefs = numRefChannels*(nchoosek(numTaps,2) + 2*numTaps);
    isLinear = 0;
elseif numTaps == 1
    numHinfRefs = numRefChannels*(nchoosek(numTaps,1) + 1*numTaps);
    isLinear = 0;
else
    numHinfRefs = numRefChannels;
    isLinear = 1;
end

if isempty(isFirstLoop)
    isFirstLoop = true;
    XnnBPFilter    = zeros(2*butterOrder,numRefChannels,numDecomp);
    cleanData      = zeros(size(inDataEEG,1),size(inDataEEG,2),numDecomp);
    if ~isLinear
        refBuffer  = zeros(numRefChannels,numTaps,numDecomp);
        disp('UHBMI: Non-Linear De-Noising')
    else
        refBuffer  = zeros(numRefChannels,1);
        disp('UHBMI: Linear De-Noising')
    end
    PtHinf         = zeros(numHinfRefs,numHinfRefs,numDecomp);
    for i=1:numDecomp
        PtHinf(:,:,i)  = 0.1*eye(numHinfRefs);
    end
    whHinf         = 0+zeros(numHinfRefs,numDataChannels,numDecomp);
    REF            = zeros(size(inDataRef,1),size(inDataRef,2),numDecomp);
    for i=1:numDecomp
        %cleanData{i} = zeros(size(inDataEEG));
        %refBuffer{i} = zeros(numRefChannels,numTaps);
        %PtHinf{i}    = 0.1*eye(numHinfRefs);
        %whHinf{i}    = 0+zeros(numHinfRefs,numDataChannels);
        %REF{i}       = zeros(size(inDataRef));
    end
else
    isFirstLoop = false;
end


%% decompose reference into frequencies


for i=1:numDecomp
    [REF(:,:,i) , XnnBPFilter(:,:,i)] = uhbmi_StateSpaceFilter( inDataRef, A(:,:,i),B(:,:,i),C(:,:,i),D(:,:,i), XnnBPFilter(:,:,i) );
end

%% Form Volterra Representation of reference and Clean using Hinf


for J = 1:numDecomp % for each target frequency
    if J==1
        indat = inDataEEG;
    else
        indat = cleanData(:,:,J-1);
    end
    
    for i=1:numTimePoints % for each time point
        
        %% Volterra Expansion of reference data
        if ~isLinear
            refBuffer(:,:,J)=[REF(i,:,J)' refBuffer(:,1:end-1,J)];
            if numTaps>1
                volterraCrossTerms = zeros(numRefChannels,nchoosek(numTaps,2));
                %Generating Cross-terms
                numLoop = 0;
                for k=1:numTaps-1
                    for j=1:numTaps-k
                        numLoop=numLoop+1;
                        volterraCrossTerms(:,numLoop) = refBuffer(:,j,J).*refBuffer(:,j+k,J);
                    end
                end
            else
                volterraCrossTerms = [];
            end
            % Final Contents of after Volterra Expansion
            volterraRef = [refBuffer(:,:,J), refBuffer(:,:,J).^2, volterraCrossTerms];
        else
            volterraRef = inDataRef';
        end
        
        
        %% HINF FILTERING
        
        [cleanData(i,:,J),~,PtHinf(:,:,J),whHinf(:,:,J)]   = uhbmi_HinfFilter(indat(i,:), volterraRef(:)', gamma, PtHinf(:,:,J), whHinf(:,:,J), q);
        %[H,~,Pt1,wh1]   = HinfFilter_COP_v1_PRT_RT_Motion_mex(indat(i,:), Vv, gamma, Pt1, wh1, q);
        
    end
end

%% Output

outData = cleanData(:,:,end);








