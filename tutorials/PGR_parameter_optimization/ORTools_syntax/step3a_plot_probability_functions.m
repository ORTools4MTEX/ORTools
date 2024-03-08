% Parameters
tol = [2.5,1.5,3.5,1.5,2];
threshold = [2.5,3.5,1.5,1.5,5.0];

% Input vector
x = 0:0.1:6;

figure;
axis; 
xlabel('Angle (°)');
ylabel('Cumulative Probability');
% Compute the CDF values for the normal distribution
for ii = 1:length(tol)
    y = 1 - 0.5 * (1 + erf(2*(x - threshold(ii))./tol(ii)));
    hold on
    plot(x, y, 'LineWidth', 2, 'DisplayName',strcat('Tol: ',num2str(tol(ii)), ", Thresh: ", num2str(threshold(ii))));
end
grid on;
legend;
