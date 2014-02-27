function out = readllresults(filename, varargin)
  %READLLRESULTS  Reads LineLength results from binary file.
  %
  %   OUT = READLLRESULTS('fileName') reads all results from the binary
  %   file that was generated by the IEEGLinelenght method into a matlab
  %   structure.
  %
  %   The binary file-format contains a header followed by the data:
  %   
  %   [HEADER]
  %   DatasetName      160 x (char)
  %   NrChannels       1 x (uint32)
  %   ChannelIndeces   NrChannels x (uint32)
  %   WinL             1 x (uint32)
  %   Overlap          1 x (uint8)
  %   SampleRate       1 x (double)
  %   [DATA]
  %
  %   Example:
  %       results = READLLRESULTS('fileName');
  %
  %   See also: IEEGLinelength
  
  fid = fopen(filename,'r');
  
  % Read header
  out = struct('name','',...
    'channels',[],...
    'winL',[],...
    'overlap',false,...
    'sampleRate',[],...
    'data',[]);
  
  out.name = strtrim(fread(fid,160,'*char')');
  nrChannels = fread(fid,1,'uint32');
  out.channels = fread(fid,nrChannels,'uint32');
  out.winL = fread(fid,1,'uint32');
  out.overlap = logical(fread(fid,1,'uint8'));
  out.sampleRate = (fread(fid,1,'double'));
  
  % Get Data
  data = fread(fid,'double');
  out.data = reshape(data, nrChannels,[])';
  fclose(fid);
  
end