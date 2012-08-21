#!/bin/sh
rm -r "printable doc"
cp -r "doc" "printable doc"
cp style.css "printable doc/style.css"
cd "printable doc/SmartSim"
~/devel/htmlbodycat/htmlbodycat \
index.htm \
Annotation.html \
Designer.html \
DesignerWindow.html \
CompiledCircuit.html \
ComponentDef.html \
ComponentInst.html \
ComponentState.html \
Connection.html \
Core.html \
Customiser.html \
Graphic.html \
Path.html \
PinDef.html \
PinInst.html \
Project.html \
PropertiesQuery.html \
PropertySet.html \
SimulatorWindow.html \
Tag.html \
WireInst.html \
WireState.html \
CustomComponentDef.html \
MemoryComponentState.html \
> everything.html

