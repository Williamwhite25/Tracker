import Foundation

enum Localizable {
    // MARK: - Common
    static let trackersTitle = NSLocalizedString("trackers_title", comment: "Main screen title with trackers list")
    static let addButton = NSLocalizedString("add_button", comment: "Add button title")
    static let cancelButton = NSLocalizedString("cancel_button", comment: "Cancel button title")
    static let createButton = NSLocalizedString("create_button", comment: "Create button title")
    static let saveButton = NSLocalizedString("save_button", comment: "Save button title")
    static let doneButton = NSLocalizedString("done_button", comment: "Done button title")
    
    // MARK: - Search
    static let searchPlaceholder = NSLocalizedString("search_placeholder", comment: "Search field placeholder")
    
    // MARK: - Placeholders
    static let noTrackersPlaceholder = NSLocalizedString("no_trackers_placeholder", comment: "Empty state placeholder when no trackers")
    static let habitsEventsGrouped = NSLocalizedString("habits_events_grouped", comment: "Placeholder text about grouping habits and events")
    
    // MARK: - Categories
    static let categoryTitle = NSLocalizedString("category_title", comment: "Category section title")
    static let scheduleTitle = NSLocalizedString("schedule_title", comment: "Schedule section title")
    static let everyDay = NSLocalizedString("every_day", comment: "Every day schedule option")
    static let newCategory = NSLocalizedString("new_category", comment: "New category screen title")
    static let addCategory = NSLocalizedString("add_category", comment: "Add category button title")
    static let categoryNamePlaceholder = NSLocalizedString("category_name_placeholder", comment: "Category name input placeholder")
    static let editCategory = NSLocalizedString("edit_category", comment: "Edit category screen title")
    
    // MARK: - Habit Creation
    static let newHabitTitle = NSLocalizedString("new_habit_title", comment: "New habit creation screen title")
    static let editHabitTitle = NSLocalizedString("edit_habit_title", comment: "Edit habit screen title")
    static let trackerNamePlaceholder = NSLocalizedString("tracker_name_placeholder", comment: "Tracker name input placeholder")
    static let emojiSection = NSLocalizedString("emoji_section", comment: "Emoji selection section title")
    static let colorSection = NSLocalizedString("color_section", comment: "Color selection section title")
    
    // MARK: - Schedule
    static let scheduleScreenTitle = NSLocalizedString("schedule_screen_title", comment: "Schedule screen title")
    
    // MARK: - Days
    static let monday = NSLocalizedString("monday", comment: "Monday full name")
    static let tuesday = NSLocalizedString("tuesday", comment: "Tuesday full name")
    static let wednesday = NSLocalizedString("wednesday", comment: "Wednesday full name")
    static let thursday = NSLocalizedString("thursday", comment: "Thursday full name")
    static let friday = NSLocalizedString("friday", comment: "Friday full name")
    static let saturday = NSLocalizedString("saturday", comment: "Saturday full name")
    static let sunday = NSLocalizedString("sunday", comment: "Sunday full name")
    
    // MARK: - Context Menu
    static let editAction = NSLocalizedString("edit_action", comment: "Edit context menu action")
    static let deleteAction = NSLocalizedString("delete_action", comment: "Delete context menu action")
    
    // MARK: - Alerts
    static let deleteConfirmationTitle = NSLocalizedString("delete_confirmation_title", comment: "Delete confirmation alert title")
    static let deleteTrackerConfirmation = NSLocalizedString("delete_tracker_confirmation", comment: "Delete tracker confirmation title")
    static let deleteConfirmationMessage = NSLocalizedString("delete_confirmation_message", comment: "Delete confirmation alert message")
    static let deleteButton = NSLocalizedString("delete_button", comment: "Delete button in alert")
    static let errorTitle = NSLocalizedString("error_title", comment: "Error alert title")
    static let errorMessage = NSLocalizedString("error_message", comment: "Generic error message")
    
    // MARK: - Tab Bar
    static let trackersTab = NSLocalizedString("trackers_tab", comment: "Trackers tab title")
    static let statisticsTab = NSLocalizedString("statistics_tab", comment: "Statistics tab title")
    
    // MARK: - Errors
    static let futureDateError = NSLocalizedString("future_date_error", comment: "Cannot mark trackers for future dates")
    
    // MARK: - Pluralization
    static func daysCount(_ count: Int) -> String {
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        
        switch currentLanguage {
        case "ru":
            let lastDigit = count % 10
            let lastTwoDigits = count % 100
            
            switch (lastDigit, lastTwoDigits) {
            case (1, 11...):
                return "\(count) дней"
            case (1, _):
                return "\(count) день"
            case (2...4, 12...14):
                return "\(count) дней"
            case (2...4, _):
                return "\(count) дня"
            default:
                return "\(count) дней"
            }
            
        default:
            switch count {
            case 1:
                return "\(count) day"
            default:
                return "\(count) days"
            }
        }
    }
    
    // MARK: - Days Short
    static let mondayShort = NSLocalizedString("monday_short", comment: "Monday short name")
    static let tuesdayShort = NSLocalizedString("tuesday_short", comment: "Tuesday short name")
    static let wednesdayShort = NSLocalizedString("wednesday_short", comment: "Wednesday short name")
    static let thursdayShort = NSLocalizedString("thursday_short", comment: "Thursday short name")
    static let fridayShort = NSLocalizedString("friday_short", comment: "Friday short name")
    static let saturdayShort = NSLocalizedString("saturday_short", comment: "Saturday short name")
    static let sundayShort = NSLocalizedString("sunday_short", comment: "Sunday short name")
    
    // MARK: - Onboarding
    static let onboardingFirstTitle = NSLocalizedString("onboarding_first_title", comment: "First onboarding screen title")
    static let onboardingSecondTitle = NSLocalizedString("onboarding_second_title", comment: "Second onboarding screen title")
    static let onboardingButton = NSLocalizedString("onboarding_button", comment: "Onboarding button title")
    
    // MARK: - Statistics
    static let statisticsTitle = NSLocalizedString("statistics_title", comment: "Statistics screen title")
    static let noStatisticsPlaceholder = NSLocalizedString("no_statistics_placeholder", comment: "Empty statistics placeholder")
    
    // MARK: - Statistics Items
    static let bestPeriod = NSLocalizedString("best_period", comment: "Best period statistic title")
    static let perfectDays = NSLocalizedString("perfect_days", comment: "Perfect days statistic title")
    static let completedTrackers = NSLocalizedString("completed_trackers", comment: "Completed trackers statistic title")
    static let averageValue = NSLocalizedString("average_value", comment: "Average value statistic title")
    
    // MARK: - Filters
    static let filtersTitle = NSLocalizedString("filters_title", comment: "Filters screen title")
    static let filtersButton = NSLocalizedString("filters_button", comment: "Filters button title")
    static let allTrackersFilter = NSLocalizedString("all_trackers_filter", comment: "All trackers filter option")
    static let todayTrackersFilter = NSLocalizedString("today_trackers_filter", comment: "Today trackers filter option")
    static let completedTrackersFilter = NSLocalizedString("completed_trackers_filter", comment: "Completed trackers filter option")
    static let uncompletedTrackersFilter = NSLocalizedString("uncompleted_trackers_filter", comment: "Uncompleted trackers filter option")
    static let nothingFound = NSLocalizedString("nothing_found", comment: "Nothing found placeholder")
}
