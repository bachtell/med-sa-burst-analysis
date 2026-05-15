function filteredC = extract_c_array(rawData, bracket)

filteredC = [];

for i = bracket(1)+1:bracket(2)

    filteredC(end+1,1) = str2double(rawData{i});

end

end
