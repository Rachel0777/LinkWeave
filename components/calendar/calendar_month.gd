extends Control

@onready var today = Time.get_datetime_dict_from_system()
@onready var year = today.year
@onready var month = today.month
@onready var month_label = %month_label
@onready var month_container = %month_container
# 把每一天给实例化过来
@onready var calendar_label_scene = preload('res://components/calendar/calendar_day.tscn')

# 一些辅助计算的东东
func is_leap_year(year: int) -> bool:
	return (year % 4 == 0 and (year % 100 != 0 or year % 400 == 0))
func get_days_in_month(year: int, month: int) -> int:
	var days_in_month: Array[int] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	if month == 2 and is_leap_year(year):
		return 29
	return days_in_month[month - 1]
func get_weekday(year: int, month: int, day: int) -> Time.Weekday:
	# Zeller's Congruence algorithm to find the day of the week
	if month < 3:
		month += 12
		year -= 1
	var k: int = year % 100
	var j: int = int(year / 100)
	var f: int = day + (13 * (month + 1) / 5) + k + (k / 4) + (j / 4) - 2 * j
	# Adjusted Zeller's Congruence for Godot's Sunday = 0
	return (f + 6) % 7 as Time.Weekday
func get_calendar_month(year: int, month: int, include_adjacent_days: bool = false, force_six_weeks: bool = false) -> Array:
	var days_in_month: int = get_days_in_month(year, month)
	var first_day_weekday: Time.Weekday = get_weekday(year, month, 1)
	var first_weekday = Time.WEEKDAY_SUNDAY
	first_day_weekday = (first_day_weekday - first_weekday + 7) % 7
	var calendar: Array = []
	var week: Array = [0, 0, 0, 0, 0, 0, 0]
	var day: int = 1 - first_day_weekday
	while day <= days_in_month or (force_six_weeks and calendar.size() < 6):
		for i in range(7):
			if day > 0 and day <= days_in_month:
				week[i] = {'year':year,'month':month,'day':day}
			elif include_adjacent_days:
				var adj_year = year
				var adj_month = month
				var adj_day = day
				if day <= 0:
					adj_month -= 1
					if adj_month < 1:
						adj_month = 12
						adj_year -= 1
					var prev_month_days: int = get_days_in_month(adj_year, adj_month)
					adj_day = prev_month_days + day
				elif day > days_in_month:
					adj_day = day - days_in_month
					adj_month += 1
					if adj_month > 12:
						adj_month = 1
						adj_year += 1
				week[i] = {'year':adj_year,'month':adj_month,'day':adj_day}
			else:
				week[i] = 0
			day += 1
		calendar.append(week.duplicate())
		week.fill(0)
	return calendar

func _ready():
	_init()
	_set_month_days()
	
func _init():
	# 先给label赋值
	var month_names = {
		1: 'January',
		2: 'February',
		3: 'March',
		4: 'April',
		5: 'May',
		6: 'June',
		7: 'July',
		8: 'August',
		9: 'September',
		10: 'October',
		11: 'November',
		12: 'December'
	}
	match month:
		1:
			month_label.text = month_names[1]
		2:
			month_label.text = month_names[2]
		3:
			month_label.text = month_names[3]
		4:
			month_label.text = month_names[4]
		5:
			month_label.text = month_names[5]
		6:
			month_label.text = month_names[6]
		7:
			month_label.text = month_names[7]
		8:
			month_label.text = month_names[8]
		9:
			month_label.text = month_names[9]
		10:
			month_label.text = month_names[10]
		11:
			month_label.text = month_names[11]
		12:
			month_label.text = month_names[12]
			
# month排版
func _set_month_days():
	var days = get_calendar_month(year,month,true,false)
	for week in days:
		for day in week:
			_add_day(day)
		
func _add_day(day:Dictionary):
	var week_day_label = calendar_label_scene.instantiate()
	week_day_label.day = day
	month_container.add_child(week_day_label)
