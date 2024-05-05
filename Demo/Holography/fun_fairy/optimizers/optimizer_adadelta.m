classdef optimizer_adadelta < handle
    %OPTIMIZER_ADAM 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        name = 'adadelta'
        mom1 = 1e-2;
        mom2 = 0;
        r1 = 0.9;
        lr = 1e-2;
    end
    
    methods
        function obj = optimizer_adadelta(mom1,mom2,beta1,lr)
            %OPTIMIZER_ADAM 构造此类的实例
            %   此处显示详细说明
            obj.mom1 = mom1;
            obj.mom2 = mom2;
            obj.r1 = beta1;
            obj.lr = lr;
        end
        
        function para_out = step(obj,para_in,grad)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            obj.mom2 = obj.r1 .* obj.mom2 + ...
                                           (1 - obj.r1) .* abs(grad).^2;

            update = (sqrt(obj.mom1) +1e-5) ./ (sqrt(obj.mom2) + 1e-5);


            obj.mom1 = obj.r1 .* obj.mom1 + (1 - obj.r1) .* update.^2; 
            para_out = para_in - obj.lr .* update ;
        end
    end
end

