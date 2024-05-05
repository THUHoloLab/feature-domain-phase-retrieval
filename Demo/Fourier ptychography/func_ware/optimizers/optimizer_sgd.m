classdef optimizer_sgd
    %OPTIMIZER_ADAM 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        name = 'sgd'
        lr = 1e-2;
    end
    
    methods
        function obj = optimizer_sgd(lr)
            %OPTIMIZER_ADAM 构造此类的实例
            %   此处显示详细说明
            obj.lr = lr;
        end
        
        function para_out = step(obj,para_in,grad)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明

            para_out = para_in - obj.lr .* grad ;
        end
    end
end

