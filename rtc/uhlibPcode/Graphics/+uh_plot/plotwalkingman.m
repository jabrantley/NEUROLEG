classdef plotwalkingman < class_plot
    properties
        l1=332; %thigh length
        l2=391; % shank length
        xp4 = 50;xp5 = 50; % foot size;
        yp4 = -50;yp5 = 80;
        hka;
        hip;knee;ankle;
        xshift; yshift; % move hip position
        res; % resolution: number of frames in one GC
    end
    methods
        %Contructor
        function this = plotwalkingman(varargin)
            this.hka = get_varargin(varargin,'hka',[]); % column format
            if ~isempty(this.hka)                
                this.hip = this.hka(:,1);
                this.knee = this.hka(:,2);
                this.ankle = this.hka(:,3);
            end
            this.xshift = get_varargin(varargin,'xshift',0);
            this.yshift = get_varargin(varargin,'yshift',0);
            this.res = get_varargin(varargin,'res',1);
            
            this.linestyle = get_varargin(varargin,'linestyle',this.linestyle);
            this.linewidth = get_varargin(varargin,'linewidth',1);
            this.linecolor = get_varargin(varargin,'linecolor','k');
            this.markerfacecolor = get_varargin(varargin,'markerfacecolor','k');
            this.showplot;
        end
        function showplot(this)
            h=deg2rad(this.hip);
            k=-deg2rad(this.knee);
            a=deg2rad(this.ankle);
            npts=length(h);
            rhipx=zeros(npts,1)+this.xshift;
            rhipz=zeros(npts,1)+this.yshift;
            rhip=[rhipx, rhipz];
            for i=1:npts
                T1{i}=[sin(h(i)) cos(h(i)) rhipx(i);...
                    -cos(h(i)) sin(h(i))  rhipz(i);...
                    0      0       1];
                rknee(i,:)=T1{i}*[this.l1;0;1];
                T2{i}=[cos(k(i)) sin(k(i)) this.l1;...
                    -sin(k(i))     cos(k(i))  0;...
                    0              0       1];
                T12{i}=T1{i}*T2{i};
                rankle(i,:)=T12{i}*[this.l2;0;1];
                T3{i}=[cos(a(i)) -sin(a(i)) this.l2;...
                    sin(a(i))     cos(a(i))  0;...
                    0              0       1];
                T123{i}=T1{i}*T2{i}*T3{i};
                rheel(i,:)=T123{i}*[this.xp4; this.yp4;1];
                rtoe(i,:)=T123{i}*[this.xp5; this.yp5;1];
            end
            %==Plot==            
            for i=1:this.res:npts
                plot([rhip(i,1),rknee(i,1)],...
                    [rhip(i,2),rknee(i,2)],'linestyle',this.linestyle,'marker','o',...
                    'color',this.linecolor,'markerfacecolor',this.markerfacecolor)
                hold on;
                plot([rknee(i,1),rankle(i,1)],...
                    [rknee(i,2),rankle(i,2)],'linestyle',this.linestyle,'marker','o',...
                    'color',this.linecolor,'markerfacecolor',this.markerfacecolor)
                plot([rankle(i,1),rtoe(i,1)],...
                    [rankle(i,2),rtoe(i,2)],'color',this.linecolor)
                plot([rankle(i,1),rheel(i,1)],...
                    [rankle(i,2),rheel(i,2)],'color',this.linecolor)
                plot([rtoe(i,1),rheel(i,1)],...
                    [rtoe(i,2),rheel(i,2)],'color',this.linecolor)
            end
        end
    end
    methods(Access=private)
    end
    methods(Static) %static method doesn't require obj
    end
end