Line-Length
===========

Calculate Line Length for datasets on the IEEG-Portal

    IEEGLINELENGTH  Calculates line length on an IEEGDataset object.
     IEEGLINELENGTH(DATASET, WINL) calculates the line length on each
     channel of the provided dataset. Linelength will be calculated using
     a window length of WINL, where WINL is the number of samples in the
     window. The results are stored in a binary file in the current MATLAB
     folder. See below for instructions on how to load the results into
     MATLAB following the analysis.
  
     By default the linelength is calculated using non-overlapping
     windows (with size WINL). You can 
  
     You can specify certain parameters for the analysis:
  
     'blockSize'   Approximate block size in microseconds requested from
                   portal per loop 
     'maxIter'     Maximum number of blocks fetched from
                   Portal 
     'outputFile'  String with name of file that should be used to
                   store the results.
     'noOverlap'   Boolean that indicates whether the results should use
                   overlapping windows or not (default TRUE)
  
  
     Example:
       IEEGLINELENGTH(DATASET, 1000, 'outputFile','Filename...')
  
       IEEGLINELENGTH(DATASET, 1000, 'noOverlap', false)
  
     --- --- --- --- --- --- --- ---
    To read line length from Binary file:
         >> fid = fopen('filename','r');
        >> data = fread(fid, 'double');
        >> data = reshape(data, nrChannels,[]);
