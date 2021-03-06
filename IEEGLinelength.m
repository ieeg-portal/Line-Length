function IEEGLinelength(dataset, winL, varargin)
  %IEEGLINELENGTH  Calculates line length on an IEEGDataset object.
  %   IEEGLINELENGTH(DATASET, WINL) calculates the line length on all
  %   channels in DATASET. It stores the linelength of non-overlapping
  %   windows in a binary file (default: 'LL_Results.bin'). WINL is a
  %   numeric that indicates the number of samples that should be included
  %   in the Line Length calculation window. 
  %
  %   Use the READLLRESULTS method to read the binary results file into
  %   MATLAB.
  %
  %   Some optional arguments can be provided to specify the behavior of
  %   the algorithm. Each argument should be followed by the new value of
  %   the argumant.
  %
  %   'channels'    [1xn] vector of channel indices in the dataset that
  %                 should be analyzed.
  %   'blockSize'   Approximate block size in microseconds requested from
  %                 portal per loop. 
  %   'maxIter'     Maximum number of blocks that will be fetched from
  %                 the Portal. Use this to specify duration of the
  %                 analysis.
  %   'outputFile'  String with name of file that should be used to
  %                 store the results.
  %   'overlap'     Boolean that indicates whether the results should use
  %                 overlapping windows or not (default FALSE).
  %
  %
  %   For Example:
  %       IEEGLinelength(dataset, 800, 'channels', ...
  %                         1:16, 'noOverlap', false);
  %
  %   See Also: READLLRESULTS
  
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
  overlap     = false;
  channels    = 1:length(dataset.channels);
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
          overlap = varargin{i+1};
        case 'channels'
          channels = varargin{i+1};
      end
    end
  end
  
  % Get Dataset properties
  duration = dataset.channels(1).get_tsdetails.getDuration;
  sf = dataset.channels(1).sampleRate;
    
  % Find number of iterations for analysis
  nrIterations = min([ceil(duration./blockSize) maxIter]);  
  
  % Prepare file, add 
  curIndex = 0;
  fid = fopen(outputFile,'w+');
  
  % Write header
  nameStr = repmat(' ',1,160);
  nameStr(1:length(dataset.snapName)) = dataset.snapName;
  nameStr = nameStr(1:160);
  fwrite(fid, nameStr,'char');
  fwrite(fid,length(channels),'uint32');
  fwrite(fid,channels,'uint32');
  fwrite(fid,winL,'uint32');
  fwrite(fid,overlap,'uint8');
  fwrite(fid, dataset.sampleRate,'double');
 
  
  % Write first value(s)
  if overlap
    write(fid, zeros(winL * length(channels),1), 'double');
  else
    fwrite(fid, zeros(1 * length(channels),1), 'double');
  end
  
  fclose(fid);
  display(sprintf('Nr iterations: %i',nrIterations));
  
  % Run analysis 
  for i = 1 : nrIterations
    fprintf('.');
    if mod(i, 100) == 0
      fprintf('\n%i ',i);
    end
    
    % Open File
    fid = fopen(outputFile,'a+');

    % Get data from IEEG-Portal
    data = dataset.getvalues(curIndex, blockSize, channels);
    
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
    if ~overlap
      LL = LL(1:winL:end,:);
    end
    
    % Append results to file
    fwrite(fid, LL', 'double');
    
    %Close file
    fclose(fid);
  end
  
end