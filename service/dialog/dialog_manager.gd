class_name DialogManager extends Service


func get_confirmation(p_text: String, p_confirm_text: String = "YES", p_cancel_text: String = "NO") -> bool:
	var uid: String = FileLocation.DIALOG_CONFIRM
	var modal: DialogConfirm = Service.scene_manager.create_scene(uid, UI.ContainerType.DIALOG)
	modal.configure(p_text, p_confirm_text, p_cancel_text)
	var result: bool = await modal.await_input()
	return result


class Data:
	const RESTORE_SETTINGS_CHECK: String = "Restore default settings?"
