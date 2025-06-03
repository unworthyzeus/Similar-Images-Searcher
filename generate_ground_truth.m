function ground_truth = generate_ground_truth(num_images, group_size)
    % Crea una celda de num_images x group_size
    ground_truth = cell(num_images, group_size);

    for i = 1:num_images
        % Determinar el grupo al que pertenece la imagen
        group_start = floor((i-1) / group_size) * group_size + 1;
        group_end = group_start + group_size - 1;
        
        % Asignar directamente las imágenes al array de celdas
        ground_truth(i, :) = arrayfun(@(x) sprintf('ukbench%05d.jpg', x-1), group_start:group_end, 'UniformOutput', false);
    end
end
