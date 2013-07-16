package org.ranapat.tasks {
	import flash.utils.describeType;
	
	internal class MetadataAnalyzer {
		public static function getMetaTags(object:Class, member:* = null, all:Boolean = false):Vector.<XML> {
			var result:Vector.<XML> = new Vector.<XML>();
			
			var _memberName:String = member? member is Function? Tools.getFunctionName(member) : member is String? member : null : null;
			var _class:Class = object;
			var xDesc:XML = describeType(_class);
			
			var _className:String = xDesc.@name;
			var xMetas:XMLList = xDesc.factory..metadata;

			var xMetaParent:XML;
			for each(var xMeta:XML in xMetas) {
				xMetaParent =  xMeta.parent();
				if (xMeta.@name.indexOf("__go_to") > -1) {
					delete xMetaParent.children()[xMeta.childIndex()];
					continue;
				}

				if (xMetaParent.name() == "factory") {
					if (member == null) {
						result.push(xMeta);
						continue;
					}
				}

				var declaredBy:String = xMetaParent.attribute("declaredBy");
				if (declaredBy && declaredBy != _className) {
					continue;
				}

				if (all || member != null) {
					if (all) {
						result.push( xMetaParent );
					} else if (xMetaParent.attribute("name") == _memberName) {
						for each (var xMetaParentMetaItem:XML in xMetaParent.metadata) {
							if (xMetaParentMetaItem.attribute("name").indexOf("__go_to") == -1) {
								result.push( xMetaParentMetaItem );
							}
						}
					}
				}
			}

			//trace(result.join("\n"));
			
			return result;
		}
	}

}