function rawData = load_medpc_file(filename)

rawData = textread(filename, '%s', ...
    'delimiter', ['\t' ':' ' ']);

end
