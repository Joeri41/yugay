-- Card ID: 50000017
-- Cyber D'va Singularity Empress - ZERO//D'VA
local s,id=GetID()
local SET_CYBER_DVA=0x5a1
function s.initial_effect(c)
    Link.AddProcedure(c,s.matfilter,2,5,s.lcheck)
    c:EnableReviveLimit()
    -- Must be Link Summoned
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(s.splimit)
    c:RegisterEffect(e0)
    -- Set a Cyber D'va Spell/Trap from Deck or GY on Link Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,{id,1})
    e1:SetCondition(s.setcon)
    e1:SetTarget(s.settg)
    e1:SetOperation(s.setop)
    c:RegisterEffect(e1)
    -- Perfect Sync total lock: opponent cannot activate cards/effects
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,1)
    e2:SetCondition(s.lockcon)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    -- Perfect Sync total lock: opponent cannot Special Summon
    local e3=e2:Clone()
    e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    c:RegisterEffect(e3)
    -- Perfect Sync total lock: opponent cannot declare attacks
    local e4=e2:Clone()
    e4:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    c:RegisterEffect(e4)
    -- Unaffected by opponent's card effects while Perfect Sync is active
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_IMMUNE_EFFECT)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCondition(s.lockcon)
    e5:SetValue(s.efilter)
    c:RegisterEffect(e5)
    -- Cannot be Tributed for a Summon or by card effects while Perfect Sync is active
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCode(EFFECT_UNRELEASABLE_SUM)
    e6:SetCondition(s.lockcon)
    e6:SetValue(1)
    c:RegisterEffect(e6)
    local e7=e6:Clone()
    e7:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    c:RegisterEffect(e7)
    -- Once per Chain, automatically rebuild equality by sending the minimum number
    local e8=Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(id,1))
    e8:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE)
    e8:SetType(EFFECT_TYPE_QUICK_O)
    e8:SetCode(EVENT_FREE_CHAIN)
    e8:SetRange(LOCATION_MZONE)
    e8:SetCountLimit(1,id,EFFECT_COUNT_CODE_CHAIN)
    e8:SetCondition(s.fixcon)
    e8:SetTarget(s.fixtg)
    e8:SetOperation(s.fixop)
    c:RegisterEffect(e8)
    -- Float if opponent makes the Link Summoned boss leave the field
    local e9=Effect.CreateEffect(c)
    e9:SetDescription(aux.Stringid(id,2))
    e9:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e9:SetProperty(EFFECT_FLAG_DELAY)
    e9:SetCode(EVENT_LEAVE_FIELD)
    e9:SetCountLimit(1,{id,2})
    e9:SetCondition(s.flcon)
    e9:SetTarget(s.fltg)
    e9:SetOperation(s.flop)
    c:RegisterEffect(e9)
end
function s.splimit(e,se,sp,st)
    return (st&SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
function s.matfilter(c,lc,sumtype,tp)
    return c:IsSetCard(SET_CYBER_DVA)
end
function s.highlink(c)
    return c:IsType(TYPE_LINK) and c:GetLink()>=3
end
function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(s.highlink,1,nil)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.setfilter(c)
    return c:IsSetCard(SET_CYBER_DVA) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then Duel.SSet(tp,g) end
end
-- This is the exact Perfect Sync comparison requested by the pack design.
function s.lockcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0) == Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
function s.efilter(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.fixcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)~=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
function s.sendfilter(c,boss)
    return c:IsSetCard(SET_CYBER_DVA) and c:IsAbleToGrave() and c~=boss
end
function s.findpair(tp,boss)
    local h=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
    local f=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
    local delta=h-f
    local hg=Duel.GetMatchingGroup(s.sendfilter,tp,LOCATION_HAND,0,nil,boss)
    local fg=Duel.GetMatchingGroup(s.sendfilter,tp,LOCATION_ONFIELD,0,nil,boss)
    for total=1,#hg+#fg do
        for x=0,total do
            local y=total-x
            if x<=#hg and y<=#fg and x-y==delta then return x,y end
        end
    end
    return nil,nil
end
function s.fixtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local x,y=s.findpair(tp,e:GetHandler())
    if chk==0 then return x~=nil end
    e:SetLabel(x,y)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,x+y,tp,LOCATION_HAND|LOCATION_ONFIELD)
end
function s.rmfilter(c)
    return c:IsAbleToRemove()
end
function s.fixop(e,tp,eg,ep,ev,re,r,rp)
    local boss=e:GetHandler()
    local x,y=s.findpair(tp,boss)
    if not x then return end
    local g=Group.CreateGroup()
    if x>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local hg=Duel.SelectMatchingCard(tp,s.sendfilter,tp,LOCATION_HAND,0,x,x,nil,boss)
        g:Merge(hg)
    end
    if y>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local fg=Duel.SelectMatchingCard(tp,s.sendfilter,tp,LOCATION_ONFIELD,0,y,y,nil,boss)
        g:Merge(fg)
    end
    if #g==0 or Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
    if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
        and Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_ONFIELD,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local rg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
        if #rg>0 then Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT) end
    end
end
function s.flcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
        and c:IsPreviousPosition(POS_FACEUP) and c:IsSummonType(SUMMON_TYPE_LINK)
        and rp==1-tp and (r&REASON_EFFECT)~=0
end
function s.linkfilter(c,e,tp)
    return c:IsSetCard(SET_CYBER_DVA) and c:IsType(TYPE_LINK) and not c:IsCode(id)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.fltg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.flop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.linkfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g==0 or Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==0 then return end
    if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE,0,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE,0,1,1,nil)
        if #sg>0 then Duel.SSet(tp,sg) end
    end
end
