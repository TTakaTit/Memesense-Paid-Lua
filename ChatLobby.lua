print("Hello")
local function Register_HandleChatCommand()
    Panorama.LoadString([[

        var m_gResponseChat = function(msg)
        {
            msg = msg.split(' ').join('\u{00A0}')
            PartyListAPI.SessionCommand('Game::Chat', 'run all xuid ' + MyPersonaAPI.GetXuid() + ' chat ->\u2029' + msg);
        }

        var m_gFindPlayer = function(str)
        {
            // Name
            for (var i=0; PartyListAPI.GetCount() > i; ++i) 
            {
                var xuid        = PartyListAPI.GetXuidByIndex(i);
                var username    = PartyListAPI.GetFriendName(xuid);
                if (username.toLowerCase().indexOf(str) != -1) 
                    return username;
            }

            // Index
            for (var i=0; PartyListAPI.GetCount() > i; ++i) 
            {
                if (parseInt(str) == i) 
                    return PartyListAPI.GetFriendName(PartyListAPI.GetXuidByIndex(i));
            }

            return '';
        }

        var m_gHandleChatCommand = function(username, msg)
        {
            var args = msg.toLowerCase().split(' ');
            var target = (args.length > 1 ? m_gFindPlayer(args[1]) : username)
            if (target.length == 0) target = username;

            if (args[0] == '!help' || args[0] == '!cmds')
            {
                var cmds = [ 
					'!create (create lobby)',
                    '!iq <partial:name>|<lobbyindex>', '!dick <partial:name>|<lobbyindex>', '!gay <partial:name>|<lobbyindex>',
                    '!8ball <question>',
                    '!loc <partial:name>',
                    '!startq or !q (start queue)', '!stopq or !s (stop queue)', 
                    '!norris (chuck norris joke)',
                ];

                msg = '\u2029';
                for (var i = 0; cmds.length > i; ++i)
                    msg += cmds[i] + '\u2029';

                return m_gResponseChat(msg);
            }

            if (args[0] == '!iq')
                return m_gResponseChat('IQ of ' + target + ' is ' +  Math.floor(Math.random() * 420) + '.');

            if (args[0] == '!dick')
                return m_gResponseChat('Dick size of ' + target + ' is ' +  Math.floor(Math.random() * 40) + ' cm.');

            if (args[0] == '!gay')
                return m_gResponseChat(target + ' is ' +  Math.floor(Math.random() * 101) + '% gay.');

            if (args[0] == '!8ball')
            {
                if (args.length > 1 && args[1].length > 1)
                {
                    var array = [ 
                        'It is certain.', 'It is decidedly so.', 'Without a doubt.', 'Yes definitely.', 'You may rely on it.', 'As I see it, yes.', 'Most likely.', 'Outlook good.', 'Yes.', 'Signs point to yes.',
                        'Reply hazy, try again.', 'Ask again later.', 'Better not tell you now.', 'Cannot predict now.', 'Concentrate and ask again.',
                        'Don\'t count on it.', 'My reply is no.', 'My sources say no.', 'Outlook not so good.', 'Very doubtful.'
                    ];

                    m_gResponseChat('[❽] ' + array[Math.floor(Math.random() * array.length)]);
                }
                else
                    m_gResponseChat('[❽] Maybe ask some question?');

                return;
            }
                
            if (args[0] == '!loc')
            {
                msg = '';

                var settings = LobbyAPI.GetSessionSettings();
                for (var i = 0; settings.members.numMachines > i; ++i) 
                {
                    var player = settings.members[`machine${i}`];

                    if (args.length > 1)
                    {
                        if (player.player0.name.toLowerCase().indexOf(target) != -1)
                        {
                            msg = player.player0.name + ' is from ' + player.player0.game.loc;
                            break;
                        }
                    }
                    else
                        msg += player.player0.name + ' is from ' + player.player0.game.loc + '\u2029';
                }

                return m_gResponseChat(msg);
            }
			
			if (args[0] == '!create')
				return FriendsListAPI.ActionInviteFriend('0', '');

            if (args[0] == '!startq' || args[0] == '!q')
                return LobbyAPI.StartMatchmaking( '', '', '', '' );

            if (args[0] == '!stopq' || args[0] == '!s')
                return LobbyAPI.StopMatchmaking();

            if (args[0] == '!norris')
            {
                $.AsyncWebRequest('https://api.chucknorris.io/jokes/random', 
                { 
                    type: "GET", complete:function(e) 
                    {
                        if (e.status == 200) 
                            m_gResponseChat(JSON.parse(e.responseText.substring(0, e.responseText.length - 1)).value)
                    }
                });
                return;
            }
        }

    ]])
end

local function Register_HandleChatMessage()
    Panorama.LoadString([[

        var m_gHandleChatMessage = function(should_handle)
        { 
            var m_gPartyChat = $.GetContextPanel().FindChildTraverse("PartyChat")
            if (!m_gPartyChat) return;
            
            var m_gChatLines = m_gPartyChat.FindChildTraverse("ChatLinesContainer")
            if (!m_gChatLines) return;
            
            m_gChatLines.Children().forEach(el => 
            {
                var child = el.GetChild(0)
                if (child && child.BHasClass('left-right-flow') && child.BHasClass('horizontal-align-left')) 
                {
                    if (!child.BHasClass('aw_handled')) 
                    {
                        child.AddClass('aw_handled');

                        try 
                        {
                            var InnerChild = child.GetChild(child.GetChildCount() - 1);
                            if (InnerChild && InnerChild.text) 
                            {
                                var Sender = $.Localize('{s:player_name}', InnerChild);
                                var Message = $.Localize('{s:msg}', InnerChild);
                                if (should_handle && Message[0] == '!')
                                    m_gHandleChatCommand(Sender, Message);
                            }
                        } 
                        catch(err) { }
                    }
                }
            })
        }

        // set old msgs as handled
        m_gHandleChatMessage(false);
    ]])
end


-- Variables
local m_NextChatMessageCheck = 0.0

-- GUI

local m_Commands            = true


local m_RegisterHandles = true
Cheat.RegisterCallback("draw", function()
    if (EngineClient.IsInGame()) then 
        m_RegisterHandles = true
        return 
    end

    if (m_RegisterHandles) then
        m_RegisterHandles = false

        Register_HandleChatCommand()
        Register_HandleChatMessage()
    end
    
    local m_RealTime = GlobalVars.realtime
    if (m_RealTime > m_NextChatMessageCheck) then
        m_NextChatMessageCheck = m_RealTime + 0.1
        Panorama.LoadString("m_gHandleChatMessage(true);")
    end
end)
