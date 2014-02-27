Line-Length
===========

    IEEGLINELENGTH  Calculates line length on an IEEGDataset object.
        IEEGLINELENGTH(DATASET, WINL) calculates the line length on all
        channels in DATASET. It stores the linelength of non-overlapping
        windows in a binary file (default: 'LL_Results.bin'). WINL is a
        numeric that indicates the number of samples that should be included
        in the Line Length calculation window. 
  
        Use the READLLRESULTS method to read the binary results file into
        MATLAB.
  
        Some optional arguments can be provided to specify the behavior of
        the algorithm. Each argument should be followed by the new value of
        the argumant.
  
        'channels'    [1xn] vector of channel indices in the dataset that
                   should be analyzed.
        'blockSize'   Approximate block size in microseconds requested from
                   portal per loop. 
        'maxIter'     Maximum number of blocks that will be fetched from
                   the Portal. Use this to specify duration of the
                   analysis.
        'outputFile'  String with name of file that should be used to
                   store the results.
        'overlap'     Boolean that indicates whether the results should use
                   overlapping windows or not (default FALSE).
  
  
        For Example:
            IEEGLinelength(dataset, 800, 'channels', ...
                           1:16, 'noOverlap', false);
  
