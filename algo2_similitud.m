function d = algo2_similitud(H1, H2, metodo)
    % Small value to avoid division by zero and log(0)
    epsVal = 1e-10;
    
    % Normalize histograms for methods that require probability distributions
    H1_norm = H1 / (sum(H1) + epsVal);
    H2_norm = H2 / (sum(H2) + epsVal);
    
    switch lower(metodo)
        case 'chi2'
            % Chi-Squared distance on normalized histograms
            d = sum(((H1_norm - H2_norm).^2) ./ (H1_norm + H2_norm + epsVal));
            
        case 'bhattacharyya'
            % Bhattacharyya distance (already normalizes)
            BC = sum(sqrt(H1_norm .* H2_norm));
            d = -log(BC + epsVal);
            
        case 'jensen-shannon'
            % Jensen-Shannon divergence
            M = 0.5 * (H1_norm + H2_norm);
            d = 0.5 * ( sum(H1_norm .* log2((H1_norm+epsVal)./(M+epsVal))) + ...
                        sum(H2_norm .* log2((H2_norm+epsVal)./(M+epsVal))) );

        case 'hellinger'
            % Hellinger Distance (variation of Bhattacharyya)
            d = sqrt(1 - sum(sqrt(H1_norm .* H2_norm)));
        
     
        case 'kl-divergence'
            % Kullback-Leibler Divergence
            d = sum(H1_norm .* log((H1_norm + epsVal) ./ (H2_norm + epsVal)));
        
       
        otherwise
            error('Método de similitud no válido');
    end
end
