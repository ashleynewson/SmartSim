/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: customiser.vala
 *   
 *   Copyright Ashley Newson 2012
 */


/**
 * User interface element used to customise a component.
 * 
 * Allows a user to design how a custom component can be used in another
 * component.
 * Used to edit names and descriptions, create a box design, and
 * configure pins.
 */
public class Customiser {
	private Gtk.Dialog dialog;
		private Gtk.HBox layoutHBox;
			private Gtk.EventBox controller;
				private Gtk.DrawingArea display;
			private Gtk.VBox controlsVBox;
				private Gtk.HBox nameHBox;
					private Gtk.Entry nameEntry;
					private Gtk.Label nameLabel;
				private Gtk.HBox descriptionHBox;
					private Gtk.Entry descriptionEntry;
					private Gtk.Label descriptionLabel;
				private Gtk.HBox labelHBox;
					private Gtk.Entry labelEntry;
					private Gtk.Label labelLabel;
				private Gtk.HBox pinHBox;
					private Gtk.SpinButton pinSpinButton;
					private Gtk.Label pinLabel;
				private Gtk.Label tagNameLabel;
				private Gtk.CheckButton requiredCheck;
				private Gtk.VBox labelTypeVBox;
					private Gtk.Label labelTypeLabel;
					private Gtk.RadioButton labelTypeNoneRadio;
					private Gtk.RadioButton labelTypeTextRadio;
					private Gtk.RadioButton labelTypeTextBarRadio;
					private Gtk.RadioButton labelTypeClockRadio;
				private Gtk.HBox pinLabelHBox;
					private Gtk.Entry pinLabelEntry;
					private Gtk.Label pinLabelLabel;
				private Gtk.Label boundsLabel;
				private Gtk.Table boundsTable;
					private Gtk.Label rightBoundLabel;
					private Gtk.SpinButton rightBoundSpinButton;
					private Gtk.Label downBoundLabel;
					private Gtk.SpinButton downBoundSpinButton;
					private Gtk.Label leftBoundLabel;
					private Gtk.SpinButton leftBoundSpinButton;
					private Gtk.Label upBoundLabel;
					private Gtk.SpinButton upBoundSpinButton;
				private Gtk.Button colourButton;
		private Gtk.Button closeButton;
	
	private Cairo.Surface gridCache;
	
	/**
	 * The custom component being edited.
	 */
	private CustomComponentDef customComponentDef;
	/**
	 * The DesignerWindow which started the customisation.
	 */
	private DesignerWindow parent;
	/**
	 * The project the component belongs to.
	 */
	private Project project;
	
	private int selectedPinID = 0;
	private PinDef selectedPin;
	/**
	 * The x position where the user drags on the display area from.
	 */
	private int xMouseStart;
	/**
	 * The y position where the user drags on the display area from.
	 */
	private int yMouseStart;
	/**
	 * The interface tag which corrisponds to //selectedPin//.
	 */
	private Tag tag;
	
	/**
	 * Start the customiser, setting the caller DesignerWindow, target 
	 * custom component and its project.
	 */
	public Customiser (DesignerWindow? parent, CustomComponentDef customComponentDef, Project project) {
		this.customComponentDef = customComponentDef;
		this.parent = parent;
		this.project = project;
		
		int tagCount = customComponentDef.count_tags ();
		
		customComponentDef.pinDefs.resize (tagCount);
		
		for (int i = 0; i < tagCount; i++) {
			if (customComponentDef.pinDefs[i] == null) {
				Tag resolvedTag = customComponentDef.resolve_tag_id(i);
				if (resolvedTag != null) {
					customComponentDef.pinDefs[i] = new PinDef (0, 0, Direction.RIGHT, resolvedTag.flow, 0, false);
				} else {
					customComponentDef.pinDefs[i] = new PinDef (0, 0, Direction.RIGHT, Flow.NONE, 0, false);
				}
			}
		}
		
		if (customComponentDef.validate_interfaces() != 0) {
			BasicDialog.warning (null, "Warning:\nCould not associate all pins with interface tags. Make sure that all tags have unique and sequential IDs starting with 0. You can cycle through the pins to check the associations.\n");
		}
		
		populate ();
		
		update_selection ();
	}
	
	/**
	 * Create a new Gtk Dialog and populate it with widgets
	 */
	private void populate () {
		dialog = new Gtk.Dialog.with_buttons ("Customise Component", parent, Gtk.DialogFlags.MODAL);
		
		Gtk.Box content = dialog.get_content_area () as Gtk.Box;
		dialog.set_default_size (600, 200);
		dialog.set_border_width (1);
		
		layoutHBox = new Gtk.HBox (false, 2);
		content.pack_start (layoutHBox, true, true, 1);
		
			controller = new Gtk.EventBox ();
			layoutHBox.pack_start (controller, true, true, 1);
			controller.button_press_event.connect (mouse_down);
			controller.button_release_event.connect (mouse_up);
			
				display = new Gtk.DrawingArea ();
				controller.add (display);
				display.expose_event.connect (() => {render_def (); return false;});
				display.configure_event.connect (() => {gridCache = null; render_def (); return false;});
			
			controlsVBox = new Gtk.VBox (false, 2);
			layoutHBox.pack_start (controlsVBox, false, true, 1);
			
				nameHBox = new Gtk.HBox (false, 2);
				controlsVBox.pack_start (nameHBox, false, true, 1);
					nameLabel = new Gtk.Label ("Name:");
					nameHBox.pack_start (nameLabel, false, true, 1);
					
					nameEntry = new Gtk.Entry ();
					nameEntry.text = customComponentDef.name;
					nameHBox.pack_start (nameEntry, true, true, 1);
				
				descriptionHBox = new Gtk.HBox (false, 2);
				controlsVBox.pack_start (descriptionHBox, false, true, 1);
					descriptionLabel = new Gtk.Label ("Description:");
					descriptionHBox.pack_start (descriptionLabel, false, true, 1);
					
					descriptionEntry = new Gtk.Entry ();
					descriptionEntry.text = customComponentDef.description;
					descriptionHBox.pack_start (descriptionEntry, true, true, 1);
				
				labelHBox = new Gtk.HBox (false, 2);
				controlsVBox.pack_start (labelHBox, false, true, 1);
					labelLabel = new Gtk.Label ("Box Label:");
					labelHBox.pack_start (labelLabel, false, true, 1);
					
					labelEntry = new Gtk.Entry ();
					labelEntry.text = customComponentDef.label;
					labelEntry.changed.connect (() => {
						customComponentDef.label = labelEntry.text;
						render_def ();
					});
					labelHBox.pack_start (labelEntry, true, true, 1);
				
				
				if (customComponentDef.pinDefs.length > 0) {
					selectedPinID = 0;
					selectedPin = customComponentDef.pinDefs[selectedPinID];
					tag = customComponentDef.resolve_tag_id(selectedPinID);
					
					pinHBox = new Gtk.HBox (false, 2);
					controlsVBox.pack_start (pinHBox, false, true, 1);
						pinLabel = new Gtk.Label ("Pin Select:");
						pinHBox.pack_start (pinLabel, false, true, 1);
						
						pinSpinButton = new Gtk.SpinButton.with_range (0, customComponentDef.pinDefs.length - 1, 1);
						pinSpinButton.value = 0;
						pinSpinButton.changed.connect (update_selection);
						pinHBox.pack_start (pinSpinButton, true, true, 1);
					
					if (tag != null) {
						tagNameLabel = new Gtk.Label ("Maps to: " + tag.text);
					} else {
						tagNameLabel = new Gtk.Label ("There is no matching tag!");
					}
					controlsVBox.pack_start (tagNameLabel, false, true, 1);
					
					requiredCheck = new Gtk.CheckButton.with_label ("Connection Required");
					requiredCheck.active = selectedPin.required;
					requiredCheck.toggled.connect (() => {
							if (selectedPin != null) {
								selectedPin.required = requiredCheck.active;
							}
						});
					controlsVBox.pack_start (requiredCheck, false, true, 1);
					
					labelTypeVBox = new Gtk.VBox (false, 0);
					controlsVBox.pack_start (labelTypeVBox, false, true, 1);
						labelTypeLabel = new Gtk.Label ("Pin labels can be text or a symbol:");
						labelTypeVBox.pack_start (labelTypeLabel, false, true, 1);
						
						labelTypeNoneRadio = new Gtk.RadioButton.with_label (null, "No Label");
						labelTypeNoneRadio.toggled.connect (update_label_type);
						labelTypeVBox.pack_start (labelTypeNoneRadio, false, true, 1);
						
						labelTypeTextRadio = new Gtk.RadioButton.with_label_from_widget (labelTypeNoneRadio, "Text");
						labelTypeTextRadio.toggled.connect (update_label_type);
						labelTypeVBox.pack_start (labelTypeTextRadio, false, true, 1);
						
						labelTypeTextBarRadio = new Gtk.RadioButton.with_label_from_widget (labelTypeNoneRadio, "Text With Bar");
						labelTypeTextBarRadio.toggled.connect (update_label_type);
						labelTypeVBox.pack_start (labelTypeTextBarRadio, false, true, 1);
						
						labelTypeClockRadio = new Gtk.RadioButton.with_label_from_widget (labelTypeNoneRadio, "Clock");
						labelTypeClockRadio.toggled.connect (update_label_type);
						labelTypeVBox.pack_start (labelTypeClockRadio, false, true, 1);
					
					pinLabelHBox = new Gtk.HBox (false, 2);
					controlsVBox.pack_start (pinLabelHBox, false, true, 1);
						pinLabelLabel = new Gtk.Label ("Pin Label:");
						pinLabelHBox.pack_start (pinLabelLabel, false, true, 1);
						
						pinLabelEntry = new Gtk.Entry ();
						pinLabelEntry.text = selectedPin.label;
						pinLabelEntry.changed.connect (() => {
							if (selectedPin != null) {
								selectedPin.label = pinLabelEntry.text;
								render_def ();
							}
						});
						pinLabelHBox.pack_start (pinLabelEntry, true, true, 1);
				}
				
				
				boundsLabel = new Gtk.Label ("Bounds define the visual size:");
				controlsVBox.pack_start (boundsLabel, false, true, 1);
				
				boundsTable = new Gtk.Table (2, 4, false);
				controlsVBox.pack_start (boundsTable, false, true, 1);
					
					rightBoundLabel = new Gtk.Label ("Right:");
					boundsTable.attach_defaults (rightBoundLabel, 0, 1, 0, 1);
					
					rightBoundSpinButton = new Gtk.SpinButton.with_range (0, (double)int.MAX, 5);
					rightBoundSpinButton.value = (double)customComponentDef.rightBound;
					rightBoundSpinButton.value_changed.connect (update_bounds);
					boundsTable.attach_defaults (rightBoundSpinButton, 1, 2, 0, 1);
					
					downBoundLabel = new Gtk.Label ("Down:");
					boundsTable.attach_defaults (downBoundLabel, 0, 1, 1, 2);
					
					downBoundSpinButton = new Gtk.SpinButton.with_range (0, (double)int.MAX, 5);
					downBoundSpinButton.value = (double)customComponentDef.downBound;
					downBoundSpinButton.value_changed.connect (update_bounds);
					boundsTable.attach_defaults (downBoundSpinButton, 1, 2, 1, 2);
					
					leftBoundLabel = new Gtk.Label ("Left:");
					boundsTable.attach_defaults (leftBoundLabel, 0, 1, 2, 3);
					
					leftBoundSpinButton = new Gtk.SpinButton.with_range ((double)int.MIN, 0, 5);
					leftBoundSpinButton.value = (double)customComponentDef.leftBound;
					leftBoundSpinButton.value_changed.connect (update_bounds);
					boundsTable.attach_defaults (leftBoundSpinButton, 1, 2, 2, 3);
					
					upBoundLabel = new Gtk.Label ("Up:");
					boundsTable.attach_defaults (upBoundLabel, 0, 1, 3, 4);
					
					upBoundSpinButton = new Gtk.SpinButton.with_range ((double)int.MIN, 0, 5);
					upBoundSpinButton.value = (double)customComponentDef.upBound;
					upBoundSpinButton.value_changed.connect (update_bounds);
					boundsTable.attach_defaults (upBoundSpinButton, 1, 2, 3, 4);
		
				colourButton = new Gtk.Button.with_label ("Background Colour");
				colourButton.clicked.connect (() => {set_colour();});
				controlsVBox.pack_start (colourButton, false, true, 1);
		
		dialog.response.connect (response_handler);
		
		closeButton = new Gtk.Button.with_label ("Close");
		dialog.add_action_widget (closeButton, Gtk.ResponseType.CLOSE);
		
		dialog.show_all ();
	}
	
	/**
	 * Signal handler for the Gtk.EventBox. Handles a mouse button down
	 * event on the display area.
	 */
	private bool mouse_down (Gdk.EventButton event) {
		xMouseStart = (int)(event.x);
		yMouseStart = (int)(event.y);
		return false;
	}
	
	/**
	 * Signal handler for the Gtk.EventBox. Handles a mouse button up
	 * event on the display area. This is when an action is taken.
	 * 
	 * Only changes the pins' positions.
	 */
	private bool mouse_up (Gdk.EventButton event) {
		Gtk.Allocation areaAllocation;
		controller.get_allocation (out areaAllocation);
		int width = areaAllocation.width;
		int height = areaAllocation.height;
		
		int halfGridSize = parent.gridSize / 2;
		
		int xCentre = width / 2;
		int yCentre = height / 2;
		int xStart = xMouseStart - xCentre;
		int yStart = yMouseStart - yCentre;
		int xEnd = (int)event.x - xCentre;
		int yEnd = (int)event.y - yCentre;
//		int xDiff = xEnd - xStart;
//		int yDiff = yEnd - yStart;
		
		int xBoardStart = xStart;
		int yBoardStart = yStart;
		int xBoardEnd = xEnd;
		int yBoardEnd = yEnd;
		
		xBoardStart += (xBoardStart > 0) ? halfGridSize : -halfGridSize;
		yBoardStart += (yBoardStart > 0) ? halfGridSize : -halfGridSize;
		xBoardStart = (xBoardStart / parent.gridSize) * parent.gridSize;
		yBoardStart = (yBoardStart / parent.gridSize) * parent.gridSize;
		xBoardEnd += (xBoardEnd > 0) ? halfGridSize : -halfGridSize;
		yBoardEnd += (yBoardEnd > 0) ? halfGridSize : -halfGridSize;
		xBoardEnd = (xBoardEnd / parent.gridSize) * parent.gridSize;
		yBoardEnd = (yBoardEnd / parent.gridSize) * parent.gridSize;
		
		stdout.printf ("Customiser Interact @ %i, %i - %i, %i\n", xBoardStart, yBoardStart, xBoardEnd, yBoardEnd);
		
//		int xBoardDiff = xBoardEnd - xBoardStart;
//		int yBoardDiff = yBoardEnd - yBoardStart;
		
//		int xBoardDiff = (int)((float)xDiff / zoom);
//		int yBoardDiff = (int)((float)yDiff / zoom);
		
//		uint button = event.button;
//		int x;
//		int y;
		
//		x = xEnd;
//		y = yEnd;
		
//		int xDiffAbs = (xDiff > 0) ? xDiff : -xDiff;
//		int yDiffAbs = (yDiff > 0) ? yDiff : -yDiff;
//		int xBoardDiffAbs = (xBoardDiff > 0) ? xBoardDiff : -xBoardDiff;
//		int yBoardDiffAbs = (yBoardDiff > 0) ? yBoardDiff : -yBoardDiff;
		
		int rightBound = customComponentDef.rightBound;
		int downBound = customComponentDef.downBound;
		int leftBound = customComponentDef.leftBound;
		int upBound = customComponentDef.upBound;
		
		if (upBound <= yBoardEnd && yBoardEnd <= downBound) {
			if (xBoardEnd < leftBound) {
				selectedPin.set_position (leftBound, yBoardEnd, leftBound - xBoardEnd, Direction.LEFT);
			}
			if (xBoardEnd > rightBound) {
				selectedPin.set_position (rightBound, yBoardEnd, xBoardEnd - rightBound, Direction.RIGHT);
			}
		}
		if (leftBound <= xBoardEnd && xBoardEnd <= rightBound) {
			if (yBoardEnd < upBound) {
				selectedPin.set_position (xBoardEnd, upBound, upBound - yBoardEnd, Direction.UP);
			}
			if (yBoardEnd > downBound) {
				selectedPin.set_position (xBoardEnd, downBound, yBoardEnd - downBound, Direction.DOWN);
			}
		}
		
		update_values ();
		
		render_def ();
		
		return false;
	}
	
	/**
	 * Called when the Customiser should become modal.
	 */
	public void run () {
		dialog.run ();
	}
	
	/**
	 * Handles the response of the customiser dialog. (On close.)
	 */
	public void response_handler (int response_id) {
		update_values ();
		dialog.destroy ();
	}
	
	public void set_colour () {
		Gtk.ColorSelectionDialog colorDialog = new Gtk.ColorSelectionDialog ("Component Background");
		Gtk.ColorSelection colorSelection = (Gtk.ColorSelection)colorDialog.get_color_selection ();
		Gdk.Color color = Gdk.Color ();
		
		colorSelection.has_opacity_control = true;
		
		color.red = (uint16)(customComponentDef.backgroundRed * 257);
		color.green = (uint16)(customComponentDef.backgroundGreen * 257);
		color.blue = (uint16)(customComponentDef.backgroundBlue * 257);
		
		if (customComponentDef.backgroundAlpha == 0) {
			colorSelection.set_previous_alpha (65535);
			colorSelection.set_current_alpha (65535);
		} else {
			colorSelection.set_previous_alpha ((uint16)(customComponentDef.backgroundAlpha * 257));
			colorSelection.set_current_alpha ((uint16)(customComponentDef.backgroundAlpha * 257));
		}
		colorSelection.set_previous_color (color);
		colorSelection.set_current_color (color);
		
		if (colorDialog.run() == Gtk.ResponseType.OK) {
			colorSelection.get_current_color (out color);
			
			customComponentDef.backgroundAlpha = (int)colorSelection.get_current_alpha() / 257;
			customComponentDef.backgroundRed = (int)color.red / 257;
			customComponentDef.backgroundGreen = (int)color.green / 257;
			customComponentDef.backgroundBlue = (int)color.blue / 257;
			
			customComponentDef.backgroundAlphaF = (double)customComponentDef.backgroundAlpha / 255.0;
			customComponentDef.backgroundRedF = (double)customComponentDef.backgroundRed / 255.0;
			customComponentDef.backgroundGreenF = (double)customComponentDef.backgroundGreen / 255.0;
			customComponentDef.backgroundBlueF = (double)customComponentDef.backgroundBlue / 255.0;
		}
		
		colorDialog.destroy ();
		
		render_def ();
	}
	
	/**
	 * Set generic information. Called when closing the dialog.
	 */
	public void update_values () {
		if (nameEntry.text != customComponentDef.name) {
			if (project.resolve_def_name(nameEntry.text) == null) {
				customComponentDef.name = nameEntry.text;
			} else {
				BasicDialog.error (null, "A component with the name \"" + nameEntry.text + "\" already exists. It may be a built-in component or a custom component. This component's name will remain \"" + customComponentDef.name + "\".");
			}
		}
		customComponentDef.description = descriptionEntry.text;
	}
	
	/**
	 * Set, from radio buttons, what type of label a pin should use.
	 */
	public void update_label_type () {
		if (selectedPin != null) {
			if (labelTypeNoneRadio.active) {
				selectedPin.labelType = PinDef.LabelType.NONE;
			} else if (labelTypeTextRadio.active) {
				selectedPin.labelType = PinDef.LabelType.TEXT;
			} else if (labelTypeTextBarRadio.active) {
				selectedPin.labelType = PinDef.LabelType.TEXTBAR;
			} else if (labelTypeClockRadio.active) {
				selectedPin.labelType = PinDef.LabelType.CLOCK;
			}
			render_def ();
		}
	}
	
	/**
	 * Set, from spin buttons, what the bounds of the component are.
	 */
	public void update_bounds () {
		customComponentDef.rightBound = rightBoundSpinButton.get_value_as_int ();
		customComponentDef.downBound = downBoundSpinButton.get_value_as_int ();
		customComponentDef.leftBound = leftBoundSpinButton.get_value_as_int ();
		customComponentDef.upBound = upBoundSpinButton.get_value_as_int ();
		
		render_def ();
	}
	
	/**
	 * Update widgets to show the information of the selected pin.
	 */
	public void update_selection () {
		if (customComponentDef.pinDefs.length > 0) {
			selectedPinID = pinSpinButton.get_value_as_int ();
			selectedPin = customComponentDef.pinDefs[selectedPinID];
			tag = customComponentDef.resolve_tag_id(selectedPinID);
			
			switch (selectedPin.labelType) {
				case PinDef.LabelType.NONE:
					labelTypeNoneRadio.set_active (true);
					break;
				case PinDef.LabelType.TEXT:
					labelTypeTextRadio.set_active (true);
					break;
				case PinDef.LabelType.TEXTBAR:
					labelTypeTextBarRadio.set_active (true);
					break;
				case PinDef.LabelType.CLOCK:
					labelTypeClockRadio.set_active (true);
					break;
			}
			
			if (tag != null) {
				tagNameLabel.label = "Maps to: " + tag.text;
				
				if (selectedPin.label == "") {
					selectedPin.label = tag.text;
				}
			} else {
				tagNameLabel.label = "There is no matching tag!";
			}
			
			pinLabelEntry.text = selectedPin.label;
			requiredCheck.active = selectedPin.required;
			
		} else {
			selectedPin = null;
		}
		
		render_def ();
	}
	
	/**
	 * Render the current box design.
	 */
	public bool render_def () {
		int width, height;
		Gtk.Allocation areaAllocation;
		
		display.get_allocation (out areaAllocation);
		width = areaAllocation.width;
		height = areaAllocation.height;
		
		Cairo.Context displayContext = Gdk.cairo_create (display.window);
		Cairo.Surface offScreenSurface = new Cairo.Surface.similar (displayContext.get_target(), Cairo.Content.COLOR, width, height);
		Cairo.Context context = new Cairo.Context (offScreenSurface);
		displayContext.set_source_surface (offScreenSurface, 0, 0);
		
		context.set_line_width (1);
		
		if ( (parent != null) ? parent.showGrid : false ) {
			if (gridCache == null) {
				gridCache = new Cairo.Surface.similar (context.get_target(), context.get_target().get_content(), width, height);
				Cairo.Context gridContext = new Cairo.Context (gridCache);
				
				gridContext.set_source_rgb (1, 1, 1);
				gridContext.paint ();
				
				float spacing = parent.gridSize;
				
				while (spacing < 2) {
					spacing *= parent.gridSize;
				}
				
				float y = ((height / 2)) % (spacing);
				float x = ((width  / 2)) % (spacing);
				
				gridContext.set_source_rgba (0, 0, 0, 0.5);
				
				gridContext.set_dash ({1.0, spacing - 1.0}, 0);
				
				for (; y < height; y += spacing) {
					gridContext.move_to (x, y);
					gridContext.line_to (width, y);
					gridContext.stroke ();
				}
				
				spacing *= 4;
				
				y = ((height / 2)) % (spacing);
				x = ((width  / 2)) % (spacing);
				
				gridContext.set_source_rgba (0, 0, 0, 1.0);
				
				gridContext.set_dash ({1.0, (spacing) - 1.0}, 0);
				
				for (; y < height; y += spacing) {
					gridContext.move_to (x, y);
					gridContext.line_to (width, y);
					gridContext.stroke ();
				}
				
				gridContext.set_dash (null, 0);
				
				gridContext.set_source_rgba (0, 0, 0, 1);
			}
			
			context.set_source_surface (gridCache, 0, 0);
			context.paint ();
		} else {
			context.set_source_rgb (1, 1, 1);
			context.paint ();
		}
		
		context.translate (width / 2, height / 2);
		
		context.set_source_rgb (0, 0, 0);
		
		customComponentDef.render (context, Direction.RIGHT, false, null, true);
		
		for (int i = 0; i < customComponentDef.pinDefs.length; i++) {
			PinDef pinDef = customComponentDef.pinDefs[i];
			
			if (selectedPinID == i) {
				context.set_source_rgb (0, 0, 1);
			} else {
				context.set_source_rgb (0, 0, 0);
			}
			
			pinDef.render (context, false);
		}
		
		displayContext.paint ();
		
		return false;
	}
}
