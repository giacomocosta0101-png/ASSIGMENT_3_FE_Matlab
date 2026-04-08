function [disc_fact,rate] = find_rate_from_bootstrap_curve(refDate,maturity)
    % FIND_RATE_FROM_BOOTSTRAP_CURVE
    % Computes the interpolated discount factor associated with a given 
    % maturity, using a bootstrapped yield curve.
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

    % Bootstrap the yield curve to obtain discount factors
    % 'dates'     = vector of maturities used in the curve
    % 'discounts' = corresponding discount factors obtained via bootstrap
    [dates, discounts, ~] = bootstrap(datesSet, ratesSet);
    base_date = dates(1);
    % We compute the settlement date (current date + 2 (adjusted to a
    % business day))
    settlement_date = business_date_offset(refDate,day_offset = 2);
   
    % We adjust the matury to a business day
    maturity = business_date_offset(maturity);
    
    % We find the discount factor corresponding to the maturity
    df_settle = get_discount_factor_by_zero_rates_linear_interp(base_date, settlement_date, dates, discounts);
    df_mat = get_discount_factor_by_zero_rates_linear_interp(base_date, maturity, dates, discounts);
    disc_fact = df_mat / df_settle;
    
    % We compute year fraction from reference_date to maturiity with
    % ACT/365 convention
    year_frac = yearfrac(settlement_date, maturity, 3);

    % We convert discount factor to continuously compounded zero rate
    rate = -log(disc_fact) / year_frac;

end