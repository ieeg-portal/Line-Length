function IEEGLinelength(dataset, winL, varargin)
  %IEEGLINELENGTH  Calculates line length on an IEEGDataset object.
  %   IEEGLINELENGTH(DATASET, WINL) 
  %
  %   'blockSize'   Approximate block size in microseconds requested from
  %                 portal per loop 
  %   'maxIter'     Maximum number of blocks fetched from
  %                 Portal 
  %   'outputFile'  String with name of file that should be used to
  %                 store the results.
  %   'noOverlap'   Boolean that indicates whether the results should use
  %                 overlapping windows or not (default TRUE)
  
  % To read line length from Binary file:
  %   >> fid = fopen('filename','r');
  %   >> data = fread(fid, 'double');
  %   >> data = reshape(data, nrChannels,[]);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Copyright 2013 Trustees of the University of Pennsylvania
  % 
  % Licensed under the Apache License, Version 2.0 (the "License");
  % you may not use this file except in compliance with the License.
  % You may obtain a copy of the License at
  % 
  % http://www.apache.org/licenses/LICENSE-2.0
  % 
  % Unless required by applicable law or agreed to in writing, software
  % distributed under the License is distributed on an "AS IS" BASIS,
  % WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  % See the License for the specific language governing permissions and
  % limitations under the License.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % LineLength function (time == rows, channels == columns):
  LLFeat = @(X, winL) conv2(abs(diff(X,1)),repmat(1/winL,winL,1), 'same');

  % BlockSize: Length of data requested per iteration from the portal.
  DEFAULTBLOCKSIZE = 1e6*60*20; %20 minutes
  
  % FILENAME: Name of the file with the results.
  DEFAULTFILENAME  = 'LineLength_Results.bin';
  
  blockSize   = DEFAULTBLOCKSIZE;
  maxIter     = nan;
  outputFile  = DEFAULTFILENAME;
  noOverlap   = true;
  if nargin > 2
    assert(mod(length(varargin),2)==0,...
      'Number of optional arguments must be even.');
    for i = 1:2:length(varargin)
      switch varargin{i}
        case 'blockSize'
          blockSize = varargin{i+1};
        case 'maxIter'
          maxIter = varargin{i+1};
        case 'outputFile'
          outputFile = varargin{i+1};
        case 'noOverlap'
          noOverlap = varargin{i+1};
      end
    end
  end
  
  % Get Dataset properties
  duration = dataset.channels(1).get_tsdetails.getDuration;
  nrChan = length(dataset.channels);
  sf = dataset.channels(1).sampleRate;
    
  % Find number of iterations for analysis
  nrIterations = min([ceil(duration./blockSize) maxIter]);  
  
  % Prepare file, add 
  curIndex = 0;
  fid = fopen(outputFile,'w+');
  
  if noOverlap
    fwrite(fid, zeros(1 * nrChan,1), 'double');
  else
    fwrite(fid, zeros(winL * nrChan,1), 'double');
  end
  
  fclose(fid);
  display(sprintf('Nr iterations: %i',nrIterations));
  
  % Run analysis 
  for i = 1 : nrIterations
    fprintf('.');
    if mod(i,100)==0
      fprintf('\n%i ',i);
    end
    
    % Open File
    fid = fopen(outputFile,'a+');

    % Get data from IEEG-Portal
    data = dataset.getvalues(curIndex, blockSize, 1:nrChan);
    
    % Trim data to be multiple of winL
    endIdx = floor(size(data,1)/winL)*winL;
    data = data(1:endIdx,:);
    
    % Calculate Line Length feature
    LL = LLFeat(data,winL);
    
    % Strip beginning and end of LL calculation
    LL = LL(winL:end-winL,:);
    
    % Update new current index
    curIndex = curIndex + (1e6*(endIdx-(2*winL)))/sf;

    % Store non-overlapping Line Length windows.
    if noOverlap
      LL = LL(1:winL:end,:);
    end
    
    % Append results to file
    fwrite(fid, LL', 'double');
    
    %Close file
    fclose(fid);
  end
  
end