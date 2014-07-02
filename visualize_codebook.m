function visualize_codebook(codebook)
%VISUALIZE_CODEBOOK Visualize a BoW codebook
%
%   visualize_codebook(codebook)
%

    
    % Reformat and normalize codebook
    codebook = codebook -  min(min(codebook));
    codebook = codebook ./ max(max(codebook));
    codebook = uint8(round(codebook * 255));
    
    % Initialize some variables
    textons_per_column = 25;
    size_patch = sqrt(size(codebook, 1));
    number_rows = ceil(size(codebook, 2) / textons_per_column);
    im = repmat(uint8(0), [number_rows * size_patch + number_rows - 1 textons_per_column * size_patch + textons_per_column - 1]);
    for i=1:size(codebook, 2)
        
        % Extract patch
        texton = reshape(codebook(:,i), [size_patch size_patch]);
            
        % Plot it on the image
        r = floor((i - 1) / textons_per_column) + 1;
        c = mod(i - 1, textons_per_column) + 1;
        im((r - 1) * size_patch + 1 + r - 1:r * size_patch + r - 1, (c - 1) * size_patch + 1 + c - 1:c * size_patch + c - 1) = texton;
    end
    
    % Display the result
    imshow(im), drawnow
    