classdef class_datetime < hgsetget;
%======================       
    properties (SetAccess = public, GetAccess = public)
        year;
        month;        
        date;
        ymd; %year month date.
        hour;
        min;
        sec;
        time; % hour min sec;
        all;
        now;
    end
    properties (SetAccess = public, GetAccess = public)
       
    end
    methods (Access = public) %Constructor
        %Constructor
        function this = class_datetime(varargin)
            this.now=clock;
            this.year=num2str(rem(this.now(1),100));
            this.month=this.twodigit(this.now(2));
            this.date=this.twodigit(this.now(3));
            this.ymd=[this.year,'-',this.month,'-',this.date];
            this.hour=this.twodigit(this.now(4));
            this.min=this.twodigit(this.now(5));
            this.sec=this.twodigit(this.now(6));
            this.time=[this.hour,'-',this.min,'-',this.sec];
            this.all=[this.ymd,'-',this.time];
        end
    end
    methods (Static)
        function y = twodigit(x)
            x=round(x);
            if x < 10
                y = ['0' num2str(x)];
            else
                y=num2str(x);
            end
        end
    end
end
