-- Card ID: 50000009
-- Cyber D'va Perfect Pitch
local s,id=GetID()
local SET_CYBER_DVA=0x5a1
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
function s.cdv(c,handler)
    return c:IsSetCard(SET_CYBER_DVA) and c:IsAbleToGrave() and c~=handler
end
function s.findpair(tp,handler)
    -- Account for this Quick-Play Spell itself leaving the S/T Zone after the Chain resolves.
    local h=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
    local f=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)-1
    local delta=h-f
    local hg=Duel.GetMatchingGroup(s.cdv,tp,LOCATION_HAND,0,nil,handler)
    local fg=Duel.GetMatchingGroup(s.cdv,tp,LOCATION_ONFIELD,0,nil,handler)
    for total=0,#hg+#fg do
        for x=0,total do
            local y=total-x
            if x<=#hg and y<=#fg and x-y==delta then return x,y end
        end
    end
    return nil,nil
end
function s.linkfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_CYBER_DVA) and c:IsType(TYPE_LINK)
end
function s.chlimit(e,rp,tp)
    return tp==rp
end
function s.rmfilter(c)
    return c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local x,y=s.findpair(tp,e:GetHandler())
    if chk==0 then return x~=nil and Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_ONFIELD,1,nil) end
    e:SetLabel(x,y)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,x+y,tp,LOCATION_HAND|LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
    if Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_MZONE,0,1,nil) then
        Duel.SetChainLimit(s.chlimit)
    end
end
function s.bottom2(tp)
    local ct=math.min(2,Duel.GetFieldGroupCount(tp,LOCATION_HAND,0))
    if ct==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,ct,ct,nil)
    if #g>0 then Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local handler=e:GetHandler()
    local x,y=s.findpair(tp,handler)
    if not x then return end
    local sg=Group.CreateGroup()
    if x>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local hg=Duel.SelectMatchingCard(tp,s.cdv,tp,LOCATION_HAND,0,x,x,nil,handler)
        sg:Merge(hg)
    end
    if y>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local fg=Duel.SelectMatchingCard(tp,s.cdv,tp,LOCATION_ONFIELD,0,y,y,nil,handler)
        sg:Merge(fg)
    end
    local sent=0
    if #sg>0 then sent=Duel.SendtoGrave(sg,REASON_EFFECT) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT) end
    if sent>=2 and Duel.Draw(tp,2,REASON_EFFECT)>0 then s.bottom2(tp) end
end
