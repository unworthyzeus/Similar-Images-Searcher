function H = algo1_indexar(ImDB_path, ImDB_name_prefix, num_images, hist_bins)
    H = zeros(num_images, hist_bins); % Matriz para almacenar histogramas

    for i = 0:num_images-1
        filename = [ImDB_path, ImDB_name_prefix, sprintf('%05d.jpg', i)];
        % Fix the parenthesis and call the functions
        hmmdImage = rgb2hmmd(im2double(imread(filename)));
        quantizedI = quantizeHMMD(hmmdImage, hist_bins);
        
        % Convert to uint8 so that imhist treats the values correctly (0–255)
        quantizedI_uint8 = uint8(quantizedI);


 %       h1 = imhist(quantizedI_uint8, hist_bins);
%        h2 = imhist(quantizedI_uint8, hist_bins);
  %      disp(norm(h1 - h2)); % This should be 0 or very close to 0
   
        % Calculate the histogram with the expected bin range
        edges = 0:hist_bins;  % bins [0,1),[1,2),...,[hist_bins-1,hist_bins)
    H(i+1, :) = histcounts(quantizedI_uint8, edges);
    end


    save('H.mat', 'H'); % Guardar histogramas en un archivo .mat

    figure(1); mesh(H); colormap('parula'); colorbar; axis('tight');
    title(['Image histograms (with ',sprintf('%03d',hist_bins),' bins)']);
    xlabel('Histogram Bins (Pixel Values)'); ylabel('Image Filename Index');
    zlabel('Number of pixels');

end