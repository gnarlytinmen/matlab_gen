function [accounts]=bank_history(path,varargin)

% Usage:
% [accounts]=bank_history(path,'account-S?.csv','account-S?.csv',...)

% Defs

S1='Regular_Shares';
S4='Student_Checking';
S7='Money_Market';
L78='Yolo_Secured_Card';
CMC='Citibank_Card';

% Import

num_accounts=numel(varargin);
accounts=struct;

for i=1:num_accounts
    tbl_name=varargin{i};
    
    cred_card=1;
    
    if isempty(strfind(tbl_name,'S1'))~=1;
       accounts.tables(i).account=S1;
       acc_inst=1;                                 % Flag which institution account is at
    elseif isempty(strfind(tbl_name,'S4'))~=1;
        accounts.tables(i).account=S4;
        acc_inst=1;
    elseif isempty(strfind(tbl_name,'S7'))~=1;
        accounts.tables(i).account=S7;
        acc_inst=1;
    elseif isempty(strfind(tbl_name,'L78'))~=1;
        accounts.tables(i).account=L78;
        acc_inst=1;
        cred_card=-1;
    elseif isempty(strfind(tbl_name,'MC'))~=1;
        accounts.tables(i).account=CMC;
        acc_inst=2;
        cred_card=-1;
    end
    
    [nums,~,table]=xlsread([path,varargin{i}]);
    
    switch acc_inst
        case 1      % YFCU
            accounts.tables(i).allbal_dates=datetime(table(2:end,1));
            accounts.tables(i).all_balances=nums(:,2)*cred_card;   % Flip sign to denote debt
            accounts.tables(i).transactions=nums(:,1)*cred_card;
        case 2      % Citibank
            accounts.tables(i).allbal_dates=datetime(table(2:end,2));
            accounts.tables(i).all_balances=[];
            accounts.tables(i).transactions=nums(:,4)*cred_card;
    end
    
    % Convert to days since start
    d=datenum(accounts.tables(i).allbal_dates);
    accounts.tables(i).days=d-d(end);
    
    % Collapse intraday balance changes to single value (last entry for
    % day)
    [a,a_b,a_ind]=unique(accounts.tables(i).days);
    bals=accounts.tables(i).all_balances;
    day_bals=zeros(numel(a),1);
    
    for j=1:numel(a)
        vals=find(a_ind==j);
        day_bals(j)=bals(vals(end));
    end
    
    accounts.tables(i).balances=day_bals;
    accounts.tables(i).dates=accounts.tables(i).allbal_dates(a_b);
end

trans_dates=[accounts.tables(1).allbal_dates;...
    accounts.tables(2).allbal_dates;...
    accounts.tables(3).allbal_dates];

transactions=[accounts.tables(1).transactions;...
    accounts.tables(2).transactions;...
    accounts.tables(3).transactions];

[trans_dates,sort_inds]=sort(trans_dates);
transactions=transactions(sort_inds);

% Collapse intraday transactions to single value
[a,a_b,a_ind]=unique(trans_dates);
trans=transactions;
day_trans=zeros(numel(a),1);

for j=1:numel(a)
    vals=find(a_ind==j);
    day_trans(j)=sum(trans(vals));
end

transactions=day_trans;
accounts.total_balance=cumsum(transactions);

% Convert to days since start
accounts.trans_dates=trans_dates(a_b);
d=datenum(accounts.trans_dates);
accounts.trans_days=d-d(1);

% Plot Individual accounts

figure;hold on;
for i=1:num_accounts
plot(accounts.tables(i).dates,accounts.tables(i).balances);
end

max_bal=max(accounts.total_balance);
plot(accounts.trans_dates,accounts.total_balance,'k');
set(gca,'YLim',[0,max_bal*1.1],'YTick',0:2000:max_bal*1.1,'Box','on');
ylabel('Account Balances ($)');
xlabel('Date');

end