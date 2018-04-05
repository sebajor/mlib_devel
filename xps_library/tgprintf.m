function ret = tgprintf(varargin)
% TGPRINTF send a message to a Telegram bot
%
% Use tgprintf() in the same way as sprintf()
% Example: tgprintf('Hello, World!');
%          tgprintf('%d + %d = %d',1,2,1+2);
% 
% You must have a .mat file named telegram_bot.mat'' with the 
% telegram bot info in order to work. The mat file must have a
% structure object with the following format:
% {'token'   : <Your bot token as string>,
%  'chat_id' : <Your bot chat id as string>}
%
% If MATLAB doesn't find this file, it with failback to fprintf.
%
% Please refer the following post 
% "Creating a Telegram bot for personal notifications"
% https://www.forsomedefinition.com/automation/creating-telegram-bot-notifications/
% 
% Seongsik Park
% seongsikpark@postech.ac.kr

str = sprintf(varargin{:});

if exist(strcat(getenv('MLIB_DEVEL_PATH'), '/telegram_bot.mat'))==2
    % load telegram data
    load(strcat(getenv('MLIB_DEVEL_PATH'), '/telegram_bot.mat'));
    % convert MATLAB string to url query string
    sendstr = urlencode(str);
    sendstr = ['https://api.telegram.org/bot',telegram_bot.('token'),...
               '/sendMessage?chat_id=',telegram_bot.('chat_id'),...
               '&text=',sendstr];

    % send a message   
    ret = urlread(sendstr); 
else
    % print to MATLAB command window
    fprintf(strcat(str, '\n'));
end
end
