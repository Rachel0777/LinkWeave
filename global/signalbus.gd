extends Node

# == 以下是灵感页面的标签有关的signal bus == 
# 定义一个灵感页面标签添加的信号
signal inspiration_tag_added(tagEn:TagEntity)
# 定义一个灵感页面标签删除的信号
signal inspiration_tag_deled(tagEn:TagEntity)

# == 下面是灵感界面有关memo的signal bus == 
# 定义一个灵感页面memo添加的信号
signal inspiration_memo_added(memoEn:MemoEntity)
# 定义一个和灵感页面删除关联文件有关的
signal inspiration_related_file_deled(filepath:String)
# 定义一个和查看灵感页面有关的
signal panel_double_clicked(memoEn:MemoEntity)
# 删除一个灵感的
signal inspiration_memo_deled(msg:String)
# ==以下是和链接有关的信号==
# 定义一个和添加链接有关的link
signal inspiration_link_add(link_id:String)
# 链接删除信号
signal inspiration_link_deled(link_id:String)
# 传递要显示的link
signal inspiration_link_show(link_id_list)
# 关闭PopUpPanel
signal window_close(msg:String)

# ==场景清单==
signal scene_list_added(scene_data:SceneEntity)
signal scene_list_clicked(scene_data:SceneEntity)

# ==人物页面==
# 定义一个灵感页面标签添加的信号
signal character_tag_added(characterEn:CharacterEntity)
# 定义一个灵感页面标签删除的信号
signal character_tag_deled(characterEn:CharacterEntity)

#定义人物相关的信号
signal character_added(characterEn:CharacterEntity)
signal character_deled(characterEn:CharacterEntity)

signal character_file_changed
signal file_changed(filename:String)

signal character_changed(msg:String)

