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
