paths.dofile('MazeBase.lua')
paths.dofile('OptsHelper.lua')
paths.dofile('MultiGoals.lua')
paths.dofile('MultiGoalsAbsolute.lua')
paths.dofile('MultiGoalsHelper.lua')
paths.dofile('CondGoals.lua')
paths.dofile('CondGoalsHelper.lua')
paths.dofile('Exclusion.lua')
paths.dofile('ExclusionHelper.lua')
paths.dofile('Switches.lua')
paths.dofile('SwitchesHelper.lua')
paths.dofile('LightKey.lua')
paths.dofile('NearSight.lua')
paths.dofile('TimedGoals.lua')
paths.dofile('Goto.lua')
paths.dofile('GotoHelper.lua')
paths.dofile('GotoHidden.lua')
paths.dofile('GotoHiddenHelper.lua')
paths.dofile('GameFactory.lua')
paths.dofile('Questions.lua')
paths.dofile('babi_ds.lua')
paths.dofile('BabiQuestions.lua')
paths.dofile('BumpEnemy.lua')
paths.dofile('StarEnemy.lua')
paths.dofile('Bullet.lua')
paths.dofile('PushableBlock.lua')
paths.dofile('PushBlock.lua')
paths.dofile('PushBlockCardinal.lua')
paths.dofile('BlockedDoor.lua')
paths.dofile('MultiAgents.lua')
paths.dofile('MultiAgentsStar.lua')
paths.dofile('MultiAgentsStarHelper.lua')
paths.dofile('GotoCardinal.lua')
paths.dofile('GotoSwitch.lua')
paths.dofile('batch.lua')

local function init_game_opts()
    local games = {}
    local helpers = {}
    games.MultiGoals = MultiGoals
    helpers.MultiGoals = MultiGoalsHelper
    games.MultiGoalsAbsolute = MultiGoalsAbsolute
    helpers.MultiGoalsAbsolute = MultiGoalsHelper
    games.CondGoals = CondGoals
    helpers.CondGoals = CondGoalsHelper
    games.Exclusion = Exclusion
    helpers.Exclusion = ExclusionHelper
    games.Switches = Switches
    helpers.Switches = SwitchesHelper
    games.GotoSwitch = GotoSwitch
    helpers.GotoSwitch = SwitchesHelper
    games.LightKey = LightKey
    helpers.LightKey = OptsHelper
    games.Goto = Goto
    helpers.Goto = GotoHelper
    games.GotoCardinal = GotoCardinal
    helpers.GotoCardinal = OptsHelper
    games.GotoHidden = GotoHidden
    helpers.GotoHidden = GotoHiddenHelper
    games.PushBlock = PushBlock
    helpers.PushBlock = OptsHelper
    games.PushBlockCardinal = PushBlockCardinal
    helpers.PushBlockCardinal = OptsHelper
    games.BlockedDoor = BlockedDoor
    helpers.BlockedDoor = OptsHelper
    games.MultiAgents = MultiAgents
    helpers.MultiAgents = OptsHelper
    games.MultiAgentsStar = MultiAgentsStar
    helpers.MultiAgentsStar = MultiAgentsStarHelper
    g_factory = GameFactory(g_opts,g_vocab,games,helpers)
    return games, helpers
end

function g_init_vocab()
    local function vocab_add(word)
        if g_vocab[word] == nil then
            g_opts.nwords = g_opts.nwords + 1 -- FIX LATER!!!
            local ind = g_opts.nwords + 1
            g_vocab[word] = ind
            g_ivocab[ind] = word
        end
    end
    g_vocab = {} -- g_tds.hash()
    g_ivocab = {} -- g_tds.hash()
    g_ivocabx = {} -- g_tds.hash()
    g_ivocaby = {} -- g_tds.hash()
    g_opts.nwords = 0

    -- general
    vocab_add('nil')
    vocab_add('empty')
    vocab_add('agent')
    for i = 1, 5 do
        vocab_add('agent' .. i)
    end
    vocab_add('goal')
    for i = 1, 10 do
        vocab_add('goal' .. i)
        vocab_add('obj' .. i)
        vocab_add('reward' .. i)
    end
    vocab_add('info')
    vocab_add('block')
    vocab_add('corner')
    vocab_add('water')
    vocab_add('visited')
    vocab_add('crumb')
    vocab_add('left')
    vocab_add('right')
    vocab_add('top')
    vocab_add('bottom')
    vocab_add('if')
    local mh = 12
    local mw = 12
    -- fix me!
    g_opts.MAXI = 10
    g_opts.MH = mh
    g_opts.MW = mw
    for y = -mh, mh do
        for x = -mw, mw do
            local w = 'y' .. y .. 'x' .. x
            vocab_add(w)
            g_ivocabx[g_vocab[w]] = x
            g_ivocaby[g_vocab[w]] = y
        end
    end

    -- for LightKey
    vocab_add('door')
    vocab_add('open')
    vocab_add('closed')
    -- for TimedGoals
    for i = 1, 10 do
        vocab_add('timer' .. i)
    end
    -- for Switch
    vocab_add('switch')
    vocab_add('task')
    vocab_add('color')
    vocab_add('same')
    for i = 1, 10 do
        vocab_add('color' .. i)
    end
    -- for DeepWater
    for i = 1, 3 do
        vocab_add('risk' .. i)
    end
    -- for Exclusion
    vocab_add('visit')
    vocab_add('all')
    vocab_add('excluding')
    vocab_add('avoid')

    -- for PushBlock
    vocab_add('pushable')
    vocab_add('push')
    vocab_add('block')

    -- for Goto
    vocab_add('go')
    vocab_add('absolute')
    for y = 1, mh do
        for x = 1, mw do
            local w = 'ay' .. y .. 'x' .. x
            vocab_add(w)
            g_ivocabx[g_vocab[w]] = x
            g_ivocaby[g_vocab[w]] = y
        end
    end

    -- for Questions:
    vocab_add('?')
    vocab_add('what')
    vocab_add('is')
    vocab_add('where')
    vocab_add('will')
    vocab_add('item')
    vocab_add('at')
    vocab_add('if')
    vocab_add('action')
    vocab_add('up')
    vocab_add('down')
    vocab_add('left')
    vocab_add('right')
    vocab_add('stop')
    vocab_add('grab')
    vocab_add('toggle')
    vocab_add('minority')
--    vocab_add('push_up')
--    vocab_add('push_down')
--    vocab_add('push_left')
--    vocab_add('push_right')
--    vocab_add('which')
--    vocab_add('pushableblock')

    -- Star
    vocab_add('BumpEnemy')
    vocab_add('bullet')
    vocab_add('enemy1')
    vocab_add('enemy2')
    vocab_add('enemy3')
    vocab_add('enemy4')
    vocab_add('enemy5')
    for s = -5, 50 do
       vocab_add('health' .. s)
    end

    for s = 0, 50 do
       vocab_add('cooldown' .. s)
    end


   -- misc
    vocab_add('step')

    if g_opts.babi then
        assert(g_opts.question_ratio > 0)
        -- this will add babi vocab
        local dict = {memvocab = g_ivocab,imemvocab = g_vocab}
        local ds = babi_ds(g_opts,dict)
        g_opts.nwords = #g_vocab
    end


end

function g_init_game()
    g_opts = paths.dofile(g_opts.games_config_path)
    local games, helpers = init_game_opts()
    if g_opts.question_ratio > 0 then
        if g_opts.babi then
            local dict = {memvocab = g_ivocab,imemvocab = g_vocab}
            local ds = babi_ds(g_opts,dict)
            g_babi = BabiQuestions(g_opts,g_vocab,games,helpers,ds)
        else
            g_questions = Questions(g_opts,g_vocab,games,helpers)
        end
    end
end

function new_game()
    if g_opts.game == '' then
        return g_factory:init_random_game()
    else
       return g_factory:init_game(g_opts.game)
    end
end