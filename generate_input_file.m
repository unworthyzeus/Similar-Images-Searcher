function generate_input_file(ImDB_name_prefix, num_images, input_file)
    % Definir el rango de imágenes disponibles
    total_images = 2000;
    
    % Verificar que num_images no sea mayor que el total disponible
    if num_images > total_images
        error('num_images no puede ser mayor que %d.', total_images);
    end

    % Seleccionar aleatoriamente num_images índices únicos dentro del rango [0, 1999]
    selected_indices = randperm(total_images, num_images) - 1; % Restamos 1 para que vaya de 0 a 1999

    % Abrir el archivo input_file para escritura
    fid = fopen(input_file, 'w');
    if fid == -1
        error('No se pudo abrir %s para escritura.', input_file);
    end
    
    % Escribir los nombres de las imágenes seleccionadas en el archivo
    for i = selected_indices
        file_name = sprintf('%s%05d.jpg', ImDB_name_prefix, i);
        fprintf(fid, '%s\n', file_name);
    end
    
    fclose(fid);
    fprintf('Archivo %s generado con %d entradas.\n', input_file, num_images);
end
