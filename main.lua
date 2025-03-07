local noteWindow, textEdit
local lastSaveTime = -1
local lastFriendClicked = nil

local function OnUpdate(dt)
	if lastSaveTime ~= -1 and lastSaveTime < api.Time:GetUiMsec() then
		lastSaveTime = -1
		local saveFile = api.File:Read("friendly_notes/notes.txt")
		saveFile.notes[lastFriendClicked] = textEdit:GetText()
		api.File:Write("friendly_notes/notes.txt", saveFile)
	end
end

function OnLoad()
  local saveFile = api.File:Read("friendly_notes/notes.txt")

	if saveFile == nil or saveFile.notes == nil then
    saveFile = { notes = { } }
    api.File:Write("friendly_notes/notes.txt", saveFile)
	end

  noteWindow = api.Interface:CreateWindow("notesWindow", "Notepad")
	noteWindow:Show(false)
  noteWindow:SetTitle("Notes for NO ONE")

  textEdit = W_CTRL.CreateMultiLineEdit("noteEdit", noteWindow)
	local wW, wH = noteWindow:GetExtent()
	textEdit:SetExtent(wW - 110, wH - 54)
	textEdit:AddAnchor("TOPLEFT", noteWindow, 60, 44)
  textEdit:SetMaxTextLength(3000)

  function textEdit:OnTextChanged()
		lastSaveTime = api.Time:GetUiMsec() + 2000
	end
	textEdit:SetHandler("OnTextChanged", textEdit.OnTextChanged)
  api.On("UPDATE", OnUpdate)
end

function OnUnload()
  if noteWindow ~= nil then
		noteWindow:Show(false)
		noteWindow = nil
	end
end

local function OpenNotes()
  if lastFriendClicked == nil then
    return
  end
  local saveFile = api.File:Read("friendly_notes/notes.txt")
  local note = saveFile.notes[lastFriendClicked] or ""
  textEdit:SetText(note)
  noteWindow:SetTitle("Notes for " .. lastFriendClicked)
  noteWindow:Show(true)
end


local popupMenu
function HidePopUpMenu(parent)
if popupMenu == nil then
  return
end
if parent ~= nil then
  if parent:GetAttachedWidget() == popupMenu then
    popupMenu:Show(false)
  end
else
  popupMenu:Show(false)
end
end
local SafeCallFunc = function(func, ...)
if func ~= nil then
  func(...)
end
end

function OnShowPopUp(popup_menu)
  local infotable = popup_menu.infoTable
  if infotable == nil then
    return
  end

  local deleteFriendIndex = nil
  for i, info in ipairs(infotable.infos) do
    if info.text == "Delete Friend" then
      deleteFriendIndex = i
      break
    end
  end

  if deleteFriendIndex == nil then
    return
  end

  local friendName = infotable.infos[deleteFriendIndex].arg
  lastFriendClicked = friendName
  local start = popup_menu.infoTable:GetPopupInfoTableCount() + 1 
  popup_menu.infoTable:AddInfo("Open Notes", OpenNotes, friendName) 
  for i = start, #popup_menu.infoTable.infos do
    local info = popup_menu.infoTable.infos[i]
    local btn = popup_menu:AddButton(info)
    function btn:OnClick()
      if info.proc ~= nil then
        info.proc(popup_menu.infoTable.target, info.arg)
        HidePopUpMenu()
        SafeCallFunc(popup_menu.infoTable.hideProcedure, self:GetParent())
      end
    end
    btn:SetHandler("OnClick", btn.OnClick)
    if info.disable == true then
      btn:Enable(false)
    end
  end
  popup_menu:Resize()
end

api.On("ShowPopUp", OnShowPopUp)

return {
  name = "Friendly Notes",
  desc = "Right Click a friend and add notes to them!",
  author = "Aguru",
  version = "1.0",
  OnLoad = OnLoad,
  OnUnload = OnUnload
}
