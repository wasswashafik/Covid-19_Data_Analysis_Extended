function [fitresult, gof] = logisticFit(x, y)
    %% Fit: 'logisticFit'.
    [xData, yData] = prepareCurveData( x, y );

    % Set up fittype and options.
    ft = fittype( 'A/(1+B*exp(-C*x))', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Algorithm = 'Trust-Region';
    opts.Robust = 'Off';

    opts.Lower = [0 0 0];
    opts.StartPoint = [max(y)*2 0.63235924622541 0.0975404049994095];

    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );
end