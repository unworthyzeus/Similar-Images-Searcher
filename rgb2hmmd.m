function hmmd = rgb2hmmd(rgb)
% RGB2HMMD Converteix una imatge RGB a l'espai de color HMMD.
%   hmmd = rgb2hmmd(rgb) converteix una imatge RGB d'entrada (matriu MxNx3 de tipus double,
%   amb valors normalitzats entre 0 i 1) a l'espai de color HMMD utilitzant la
%   formulació {H, Diff, Sum}, on:
%
%       H    - To (en graus, de 0 a 360)
%       Diff - La diferència entre les components màxima i mínima del RGB
%       Sum  - La mitjana entre les components màxima i mínima del RGB
%
% Aquesta conversió es basa en la definició dels Descriptors de Color MPEG-7,
% que utilitzen HMMD per al Descriptor d'Estructura del Color.
%
% Entrada:
%   rgb - Imatge RGB MxNx3 (double, valors en [0,1])
%
% Sortida:
%   hmmd - Imatge MxNx3 on:
%          hmmd(:,:,1) conté el To,
%          hmmd(:,:,2) conté la diferència (Diff),
%          hmmd(:,:,3) conté la suma (Sum).

% Extreu els canals individuals R, G, B
R = rgb(:,:,1);
G = rgb(:,:,2);
B = rgb(:,:,3);

% Calcula els valors màxim i mínim entre els canals RGB per a cada píxel
maxVal = max(cat(3, R, G, B), [], 3);
minVal = min(cat(3, R, G, B), [], 3);

% Calcula Diff i Sum
Diff = maxVal - minVal;
Sum = (maxVal + minVal) / 2;

% Inicialitza el Hue amb zeros
Hue = zeros(size(R));

% Per evitar divisions per zero, crea una màscara per als píxels on Diff és diferent de zero
nonZeroDiff = Diff > 0;

% Calcula el to només per als píxels amb Diff diferent de zero
% Per aquests píxels, determina quin canal és el màxim:
%   Si R és el màxim, utilitza la fórmula corresponent
maskR = nonZeroDiff & (R == maxVal);
Hue(maskR) = 60 * mod( (G(maskR) - B(maskR)) ./ Diff(maskR), 6 );

%   Si G és el màxim, utilitza la fórmula corresponent
maskG = nonZeroDiff & (G == maxVal);
Hue(maskG) = 60 * ( (B(maskG) - R(maskG)) ./ Diff(maskG) + 2 );

%   Si B és el màxim, utilitza la fórmula corresponent
maskB = nonZeroDiff & (B == maxVal);
Hue(maskB) = 60 * ( (R(maskB) - G(maskB)) ./ Diff(maskB) + 4 );

% Per als píxels on Diff és zero (acromàtics), el Hue es manté a 0
% Opcionalment, es podria assignar un valor fix (p. ex., 0) per indicar absència de hue.

% Combina els canals en la sortida HMMD.
% Nota: L'espai de color HMMD aquí es representa com {H, Diff, Sum}
hmmd = cat(3, Hue, Diff, Sum);

end
