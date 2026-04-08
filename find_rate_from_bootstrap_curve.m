function [disc_fact, rate] = find_rate_from_bootstrap_curve(refDate, maturity)
    % FIND_RATE_FROM_BOOTSTRAP_CURVE
    % Computes the interpolated discount factor and zero rate associated 
    % with a given maturity, using a bootstrapped yield curve.
    %
    % INPUT:
    %   refDate   = valuation date
    %   maturity  = target maturity 
    %
    % OUTPUT:
    %   disc_fact = discount factor corresponding to the requested maturity
    %   rate      = zero rate corresponding to the requested maturity
   
    % Settings
    formatData = 'dd/mm/yyyy';   % Date format 
    
    % Read market data (dates and quoted market rates) from Excel
    [datesSet, ratesSet] = readExcelData('MktData_CurveBootstrap.xls', formatData);
    
    % Bootstrap the yield curve to obtain zero rates directly
    % 'dates'     = vector of maturities used in the curve
    % 'discounts' = corresponding discount factors
    % 'zeroRates' = corresponding continuously compounded zero rates
    [dates, discounts, zeroRates] = bootstrap(datesSet, ratesSet);
    
    % We adjust the maturity to a business day
    maturity = business_date_offset(maturity);
    
    % We interpolate directly on the continuously compounded zero rates
    % (Interpolating zero rates instead of discount factors is the standard 
    % financial practice to avoid forward rate instability)
    rate = interp1(dates, zeroRates, maturity, 'linear', 'extrap');
    
    % We compute the year fraction from the start date of the bootstrap curve 
    % to the adjusted maturity (ACT/365 convention)
    year_frac_from_curve_start = yearfrac(dates(1), maturity, 3);
    
    % We compute the clean discount factor using the interpolated rate
    disc_fact = exp(-rate * year_frac_from_curve_start);
    
end