classdef pge_electric
    % Electricity bill
    
    properties
        units = [];
        energy = [];
    end
    
    methods
        function obj = pge_electric(path,filename)
            path = '/home/';
            filename = 'electric_data.csv';
            T = readtable([path,filename],'HeaderLines',5);
            
            obj.units = T{1,6};
            obj.energy = T{:,5};
        end
    end
end
