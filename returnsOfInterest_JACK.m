function [tSelected, returnsSelected, pricesAligned] = returnsOfInterest(inputFile, refDate, timeWindow, sharesList, formatDate)
if(nargin < 5)
    formatDate = 'dd/mm/yyyy';
end

elementsBasket = size(sharesList, 1);

% ===== READ DATA (cross-platform) =====
raw = readcell(inputFile, 'Sheet', 'Data', 'Range', 'A5:CX1295');
[nRows, nCols] = size(raw);

% Build header map: odd columns have asset names
headers = cell(1, nCols);
for c = 1:nCols
    if ischar(raw{1,c}) || isstring(raw{1,c})
        headers{c} = strtrim(char(raw{1,c}));
    else
        headers{c} = '';
    end
end

% ===== HELPER: find asset column index (odd col with name match) =====
    function col = findCol(name)
        col = [];
        for cc = 1:2:nCols
            if ~isempty(strfind(headers{cc}, name))
                col = cc;
                return;
            end
        end
        error('Asset "%s" non trovato nel file.', name);
    end

% ===== HELPER: extract dates and prices for a given asset =====
    function [dates, prices] = extractSeries(col)
        dateCol = col;      % odd column = dates (datetime)
        priceCol = col + 1; % even column = prices (double)
        % Find valid rows (price is numeric and non-NaN)
        mask = false(nRows-1, 1);
        vals = NaN(nRows-1, 1);
        dts  = NaT(nRows-1, 1);
        for rr = 2:nRows
            v = raw{rr, priceCol};
            d = raw{rr, dateCol};
            if isnumeric(v) && ~isnan(v) && isdatetime(d)
                mask(rr-1) = true;
                vals(rr-1) = v;
                dts(rr-1)  = d;
            end
        end
        prices = vals(mask);
        dates  = datenum(dts(mask));
    end

% ===== GET INDEX DATES (SX5E) =====
idxCol = findCol('SX5E Index');
[t_index, ~] = extractSeries(idxCol);

% ===== SELECT DATE WINDOW =====
refDate = datenum(refDate);
[refDate, idxStart] = closestDate(refDate, t_index);
endDate = dateAddMonth(refDate, timeWindow);
[~, idxEnd] = closestDate(endDate, t_index);
% Assicura che idxStart < idxEnd
if idxStart > idxEnd
    [idxStart, idxEnd] = deal(idxEnd, idxStart);
end
tSelected = t_index(idxStart:idxEnd);

% ===== GET SHARE PRICES =====
valuesSelectedShares = zeros(idxEnd - idxStart + 1, elementsBasket);
for i = 1:elementsBasket
    bbgCode = underlyingCode(sharesList(i,:));
    col_i = findCol(bbgCode);
    [t_share, prices_share] = extractSeries(col_i);
    [~, idxShare] = arrayfun(@(d) closestDate(d, t_share), tSelected);
    valuesSelectedShares(:, i) = prices_share(idxShare);
end

returnsSelected = log(valuesSelectedShares(2:end,:) ./ valuesSelectedShares(1:end-1,:));
tSelected = tSelected(2:end);
pricesAligned = valuesSelectedShares(1:end-1, :);

end % returnsOfInterest