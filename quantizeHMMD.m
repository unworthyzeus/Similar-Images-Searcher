function cellIdx = quantizeHMMD(hmmd, numCells)
    % Quantize HMMD into numCells = 256, 128, 64 o 32 según MPEG-7 Table 13.2

    [M, N, ~] = size(hmmd);
    H = hmmd(:,:,1); Diff = hmmd(:,:,2)*255; SumVal = hmmd(:,:,3)*255;

    switch numCells
        case 256
            subspaces = 5;
            bounds = [6,20,60,110,256];
            hueBinsTable = [1, 4,16,16,16];
            sumBinsTable = [32, 8, 4, 4, 4];
        case 128
            subspaces = 5;
            bounds = [6,20,60,110,256];
            hueBinsTable = [1, 4, 8, 8, 8];
            sumBinsTable = [16, 4, 4, 4, 4];
        case 64
            subspaces = 5;
            bounds = [6,20,60,110,256];
            hueBinsTable = [1, 4, 4, 8, 8];
            sumBinsTable = [ 8, 4, 4, 2, 2];
        case 32
            subspaces = 4;  % subespacios 1 y 2 fusionados
            bounds = [6,60,110,256];
            hueBinsTable = [1, 4, 8, 8];
            sumBinsTable = [ 8, 2, 1, 1];
        otherwise
            error('numCells must be 256, 128, 64 o 32.');
    end

    % Offset acumulado
    cellsPerSub = hueBinsTable .* sumBinsTable;
    offsets = [0, cumsum(cellsPerSub(1:end-1))];

    cellIdx = zeros(M,N);
    lower = [0, bounds(1:end-1)];
    for s = 1:subspaces
        mask = Diff >= lower(s) & Diff < bounds(s);
        if ~any(mask,'all'), continue; end

        hBins = hueBinsTable(s);  sBins = sumBinsTable(s);
        qH = floor(H(mask) / (360 / hBins)); 
        qH(qH>=hBins) = hBins-1;
        qS = floor(SumVal(mask) / (256 / sBins));
        qS(qS>=sBins) = sBins-1;

        localIdx = qH * sBins + qS;
        cellIdx(mask) = offsets(s) + localIdx;
    end
end
