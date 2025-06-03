
% --- EN ALGO3_BUSQUEDA ------------------------------------------
function algo3_busqueda(H, ImDB_path, ImDB_name_prefix, input_file, ...
                        output_file, hist_bins, metodo, num_candidatos)
    Q = textread(input_file, '%s');
    edges = 0:hist_bins;

    fid = fopen(output_file,'w');
    for iq = 1:numel(Q)
        qname = Q{iq};
        fprintf(fid,'Retrieved list for query image %s\n',qname);

        % 1) Histograma query exactamente igual a how indexaste H:
        I = im2double(imread(fullfile(ImDB_path,qname)));
        hmmdQ = rgb2hmmd(I);
        qQ = quantizeHMMD(hmmdQ, hist_bins);
        qQ = uint8(qQ);
        Hq = histcounts(qQ, edges);       % ¡ningún píxel se pierde!
        Hq = Hq / sum(Hq);                % normalizo

        % 2) Calculo distancias
        D = zeros(size(H,1),1);
        for j = 1:size(H,1)
            D(j) = algo2_similitud(Hq, H(j,:), metodo);
        end

        % 3) Ordeno y saco top‐k
        [~, idx] = sort(D);
        for k = 1:num_candidatos
            fprintf(fid, 'ukbench%05d.jpg\n', idx(k)-1);
        end
        fprintf(fid,'\n');
    end
    fclose(fid);
end