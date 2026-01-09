% Hard vs Soft Thresholding with Dashed Threshold Lines
T = 0.4;                           % Threshold
w = linspace(-1, 1, 500);          % Coefficient range

% Hard thresholding
w_hard = w;
w_hard(abs(w) <= T) = 0;

% Soft thresholding
w_soft = sign(w) .* max(abs(w) - T, 0);

% Plot
figure; hold on; grid on;

plot(w, w_hard, 'LineWidth', 2);
plot(w, w_soft, 'LineWidth', 2);

% Dashed vertical threshold lines
xline(T, '--', 'LineWidth', 1.2);
xline(-T, '--', 'LineWidth', 1.2);

xlabel('Original coefficient w');
ylabel('Thresholded coefficient w''');
title('Hard vs Soft Thresholding');
legend('Hard Thresholding', 'Soft Thresholding', 'Location', 'NorthWest');
set(gca, 'FontSize', 12);

% Save figure for LaTeX
saveas(gcf, 'hard_soft_thresholding_T_lines.png');
