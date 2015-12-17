local MultiGoals, parent = torch.class('MultiGoals', 'MazeBase')

function MultiGoals:__init(opts, vocab)
    parent.__init(self, opts, vocab)

    self.goal_cost = self.costs.goal
    self.costs.goal = 0

    assert(self.ngoals > 0)
    self:add_default_items()

    for i = 1, self.ngoals do
        self:place_item_rand({type = 'goal', name = 'goal' .. i})
    end

    -- objective
    self.goals = self.items_bytype['goal']
    self.ngoals_active = opts.ngoals_active
    if true then
        self.goal_order = torch.randperm(self.ngoals):narrow(1,1,self.ngoals_active)
        for i = 1, opts.ngoals_active do
            if i > self.ngoals_active then
                self:add_item({type = 'info'})
            else
                local g = self.goals[self.goal_order[i]]
                self:add_item({type = 'info', name = 'obj' .. i, target = g.name})
            end
        end
    else
        self.goal_order = {}
        if torch.uniform() < 0.5 then
            if torch.uniform() < 0.5 then
                self:add_spatial_objective('left')
                if self.ngoals_active > 1 then
                    self:add_spatial_objective('right')
                end
            else
                self:add_spatial_objective('right')
                if self.ngoals_active > 1 then
                    self:add_spatial_objective('left')
                end
            end
        else
            if torch.uniform() < 0.5 then
                self:add_spatial_objective('top')
                if self.ngoals_active > 1 then
                    self:add_spatial_objective('bottom')
                end
            else
                self:add_spatial_objective('bottom')
                if self.ngoals_active > 1 then
                    self:add_spatial_objective('top')
                end
            end
        end
    end
    self.goal_reached = 0
end

function MultiGoals:add_spatial_objective(dir)
    local tx = nil
    local ty = nil
    local ti = nil
    for i, g in ipairs(self.goals) do
        local update = false
        if ti == nil then
            update = true
        elseif dir == 'left' then
            if tx > g.loc.x then update = true end
        elseif dir == 'right' then
            if tx < g.loc.x then update = true end
        elseif dir == 'top' then
            if ty > g.loc.y then update = true end
        elseif dir == 'bottom' then
            if ty < g.loc.y then update = true end
        end
        if update then
            tx = g.loc.x
            ty = g.loc.y
            ti = i
        end
    end
    self.goal_order[#self.goal_order+1] = ti
    self:add_item({type = 'info', name = 'obj' .. #self.goal_order, target = dir})
end

function MultiGoals:update()
    parent.update(self)
    if self.goal_reached < self.ngoals_active then
        local k = self.goal_order[self.goal_reached + 1]
        local g = self.goals[k]
        if g.loc.y == self.agent.loc.y and g.loc.x == self.agent.loc.x then
            self.goal_reached = self.goal_reached + 1
            if self.flag_visited == 1 then
                g.attr.visited = 'visited'
            end
            if self.goal_reached == self.ngoals_active then
                self.finished = true
            end
        end
    end
end

function MultiGoals:get_reward()
    if self.finished then
        return -self.goal_cost
    else
        return parent.get_reward(self)
    end
end


function MultiGoals:get_supervision()
    if not self.ds then
        local ds = paths.dofile('search.lua')
        self.ds = ds
    end
    self:flatten_cost_map()
    local acount = 0
    local H = self.map.height
    local W = self.map.width
    local X = {}
    local ans = torch.zeros(self.ngoals_active*H*W)
    local rew = torch.zeros(self.ngoals_active*H*W)
    for s = 1, self.goal_order:size(1) do
        local gid = self.goal_order[s]
        local dh = self.items_bytype['goal'][gid].loc.y
        local dw = self.items_bytype['goal'][gid].loc.x
        acount = self:search_move_and_update(dh,dw,X,ans,rew,acount)
        if self.crumb_action==1 then
            acount = acount + 1
            X[acount] = self:to_sentence()
            ans[acount] = self.agent.action_ids['breadcrumb']
            self:act(ans[acount])
            self:update()
            rew[acount] = self:get_reward()
        end
    end
    -- if self.agent.action_ids['stop'] then
    --     acount = acount + 1
    --     X[acount] = self:to_sentence()
    --     ans[acount] = self.agent.action_ids['stop']
    --     rew[acount] = self:get_reward()
    -- end
    if acount == 0 then
        ans = nil
        rew = 0
    else
        ans = ans:narrow(1,1,acount)
        rew = rew:narrow(1,1,acount)
    end
    return X,ans,rew
end


function MultiGoals:d2a(dy,dx)
    local lact
    if dy< 0 then
        lact = 'up'
    elseif dy> 0 then
        lact = 'down'
    elseif dx> 0 then
        lact = 'right'
    elseif dx< 0 then
        lact = 'left'
    end
    return self.agent.action_ids[lact]
end