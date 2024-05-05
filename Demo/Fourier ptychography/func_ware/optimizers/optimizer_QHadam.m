classdef optimizer_QHadam < handle
    %OPTIMIZER_ADAM 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        name = 'QHadam'
        mom1 = 0;
        mom2 = 0;
        r1 = 0.9;
        r2 = 0.999;
        lr = 1e-2;

        v1 = 0;
        v2 = 0;
    end
    
    methods
        function obj = optimizer_QHadam(mom1,mom2,beta1,beta2,v1,v2,lr)
            %OPTIMIZER_ADAM 构造此类的实例
            %   此处显示详细说明
            obj.mom1 = mom1;
            obj.mom2 = mom2;
            obj.r1 = beta1;
            obj.r2 = beta2;
            obj.lr = lr;

            obj.v1 = v1;
            obj.v2 = v2;
        end
        
        function para_out = step(obj,para_in,grad,iter)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            obj.mom1 = obj.r1 .*  obj.mom1 + ...
                                           (1 - obj.r1) .* grad;
            obj.mom2 = obj.r2 .*  obj.mom2 + ...
                                           (1 - obj.r2) .* abs(grad).^2;

            bias = sqrt(1-obj.r2.^iter)./(1-obj.r1.^iter);

            update = bias .* (obj.v1 .* obj.mom1 + (1 - obj.v1) .* grad)./...
                 (sqrt(      obj.v2 .* obj.mom2 + ...
                       (1 - obj.v2) .* abs(grad).^2 ) + 1e-5);
            
            para_out = para_in - obj.lr .* update ;
        end
    end
end

