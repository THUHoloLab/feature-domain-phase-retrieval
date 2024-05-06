classdef optimizer_lion < handle
    %OPTIMIZER_ADAM 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        name = 'lion'
        mom1 = 0;
        mom2 = 0;
        r1 = 0.9;
        r2 = 0.999;
        lr = 1e-2;
    end
    
    methods
        function obj = optimizer_lion(mom1,mom2,beta1,beta2,lr)
            %OPTIMIZER_ADAM 构造此类的实例
            %   此处显示详细说明
            obj.mom1 = mom1;
            obj.mom2 = mom2;
            obj.r1 = beta1;
            obj.r2 = beta2;
            obj.lr = lr;
        end
        
        function para_out = step(obj,para_in,grad)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            obj.mom1 = sign(obj.r1 .*  obj.mom2 + ...
                                           (1 - obj.r1) .* grad);

            para_out = para_in - obj.lr .* obj.mom1 ;

            obj.mom2 = obj.r2 .* obj.mom2 + (1 - obj.r2) .* grad;

        end
    end
end

