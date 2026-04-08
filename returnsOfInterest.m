function [tSelected, returnsSelected, pricesAligned] = returnsOfInterest(inputFile, refDate, timeWindow, sharesList, formatDate)
% Selects set of dates and returns in a lag of interest
% [tSel returnsSel] = returnsOfInterest(inputFile, refDate, timeWindow, sharesList)
%
% INPUTS:
% - inputFile:  complete excel file name (with path) 
% - refDate:    first date of interest
% - timeWindow: in months
% - sharesList: list of the N Shares of Interest
% - formatDate: format used for dates (default 'mm/dd/yyyy')
% 
% OUTPUTS:
% - tSelected:  vector with the T dates of interest 
% - returnsSel: matrix with TxN returns values
% - pricesAligned: T×N matrix of aligned prices 
%
% USES:
% - findSeries: given the set of data selects the asset of interest
% - dateAddMonth: adds to a month a given number of months
% - closestDate: selects the nearest (even the previous one) to a given date
% - underlyingCode: Converts share name in bbg code 

if(nargin <5)
    formatDate = 'mm/dd/yyyy';
end

elementsBasket = size(sharesList,1);

% Load historical data
[shareData.num,shareData.cell]=xlsread(inputFile,'Data','a5:cx1295');

% Select the set of dates of interest: the ones in Eurostoxx50
[~, t_index]=findSeries(shareData,'SX5E Index', formatDate);

% refDate, endDate
refDate=datenum(refDate); 
[refDate, idxStart] = closestDate(refDate, t_index);
endDate = dateAddMonth(refDate, timeWindow);
[~, idxEnd] = closestDate(endDate, t_index);

idx1 = min(idxStart, idxEnd);
idx2 = max(idxStart, idxEnd);
tSelected = t_index(idx1:idx2);

% Prices of the selected shares
% If the value is not present I take the value from the previous date 
valuesSelectedShares = zeros(length(tSelected), elementsBasket);

for i = 1:elementsBasket
    bbgCode = underlyingCode(sharesList(i,:));
    [values_share, t_share] = findSeries(shareData, bbgCode, formatDate);
    
    % For each underlying in the pft I check that it is present 
    % in the time-interval of interest otherwise I take previous business day
    
    % For every date in the share series, we find the closest date 
    [~, idxShare] = arrayfun(@(d) closestDate(d, t_share), tSelected);

    % Store the aligned prices in the output matrix.
    valuesSelectedShares(:,i) = values_share(idxShare);
end

returnsSelected=log(valuesSelectedShares(2:end,:)./valuesSelectedShares(1:end-1,:));
tSelected = tSelected(2:end);
pricesAligned = valuesSelectedShares(1:end, :);

end %returnsOfInterest