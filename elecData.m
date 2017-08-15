classdef elecData
    % Electricity bill
    
    properties
        units = [];
        energy = [];
        costs = [];
        times = [];
        dates = [];
    end
    
    methods
        function obj = elecData(path,filename)
            % Suppress MATLAB's warning about modifying table variable names
            warning('off','MATLAB:table:ModifiedVarnames');
            
            % Import downloaded .csv and discard header lines
            T = readtable([path,filename],'HeaderLines',5);
            
            obj.units = char(T{1,6});
            obj.energy = T{:,5};
            
            
            
            obj.costs = T{:,7};           
            obj.times = T{:,3};
            obj.dates = T{:,2};
        end
    end
end