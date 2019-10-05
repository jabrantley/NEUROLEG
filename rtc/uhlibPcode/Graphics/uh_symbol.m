classdef uh_symbol < handle & hgsetget    
    properties
        circle;
        triangle;
        square;
        diamond;
        left_triangle;
        right_triangle;
        ast;
        box;
        pm;
        defaultlist;
        % Greek Symbol
        alpha;
        beta;
        gamma;
        Gamma;
        delta;
        Delta;
        epsilon;
        zeta;
        eta;
        theta;
        thetah;
        thetak;
        thetaa;
        Theta;
        lamda;
        Lamda;
        mu;
        nu
        pi;
        Pi;
        sigma;
        Sigma;
        phi;
        Phi;
        omega;
        Omega;
        val;
    end
    methods (Access = public) %Constructor
        %Constructor
        function this = uh_symbol(varargin);
            if nargin == 0
            else
                this.val = sprintf('$$ \\%s $$',varargin{1});
            end
            this.circle = sprintf('$$ \\circ $$');
            this.triangle = sprintf('$$ \\blacktriangle $$');
            this.left_triangle = sprintf('$$ \\triangleleft $$');
            this.right_triangle = sprintf('$$ \\triangleright $$');
            this.square = sprintf('$$ \\box $$');
            this.diamond = sprintf('$$ \\diamond $$');
            this.ast = sprintf('$$ \\ast $$');
            this.pm = sprintf('$$ \\pm $$');
            this.defaultlist = {'o','^','square','diamond','v','>','<','+','*','.','x'};
            % Greek Character
            this.alpha = sprintf('$$\\alpha $$');
            this.beta = sprintf('$$ \\beta $$');
            this.gamma = sprintf('$$ \\gamma $$');
            this.Gamma = sprintf('$$ \\Gamma $$');
            this.delta = sprintf('$$ \\delta $$');
            this.Delta = sprintf('$$ \\Delta $$');
            this.epsilon = sprintf('$$ \\epsilon $$');
            this.zeta = sprintf('$$ \\zeta $$');
            this.eta = sprintf('$$ \\eta $$');
            this.theta = sprintf('$$ \\theta $$');
            this.thetah = sprintf('$$ \\it\\theta_{h} $$');
            this.thetak = sprintf('$$ \\it\\theta_{k} $$');
            this.thetaa = sprintf('$$ \\it\\theta_{a} $$');
            this.Theta = sprintf('$$ \\Theta $$');
            this.lamda = sprintf('$$ \\lambda $$');
            this.Lamda = sprintf('$$ \\Lambda $$');
            this.mu = sprintf('$$ \\mu $$');
            this.nu = sprintf('$$ \\nu $$');
            this.pi = sprintf('$$ \\pi $$');
            this.Pi = sprintf('$$ \\Pi $$');
            this.sigma = sprintf('$$ \\sigma $$');
            this.Sigma = sprintf('$$ \\Sigma $$');
            this.phi = sprintf('$$ \\phi $$');
            this.Phi = sprintf('$$ \\Phi $$');
            this.omega = sprintf('$$ \\omega $$');
            this.Omega = sprintf('$$ \\Omega $$');
        end        
    end    
end
        
