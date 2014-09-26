/* db-gtk.h generated by valac 0.26.0, the Vala compiler, do not modify */


#ifndef __DB_GTK_H__
#define __DB_GTK_H__

#include <glib.h>
#include <glib-object.h>
#include <stdlib.h>
#include <string.h>
#include <gee.h>
#include <db.h>
#include <gtk/gtk.h>

G_BEGIN_DECLS


#define DB_TYPE_PROPERTY_ADAPTER (db_property_adapter_get_type ())
#define DB_PROPERTY_ADAPTER(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), DB_TYPE_PROPERTY_ADAPTER, DBPropertyAdapter))
#define DB_PROPERTY_ADAPTER_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), DB_TYPE_PROPERTY_ADAPTER, DBPropertyAdapterClass))
#define DB_IS_PROPERTY_ADAPTER(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), DB_TYPE_PROPERTY_ADAPTER))
#define DB_IS_PROPERTY_ADAPTER_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), DB_TYPE_PROPERTY_ADAPTER))
#define DB_PROPERTY_ADAPTER_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), DB_TYPE_PROPERTY_ADAPTER, DBPropertyAdapterClass))

typedef struct _DBPropertyAdapter DBPropertyAdapter;
typedef struct _DBPropertyAdapterClass DBPropertyAdapterClass;
typedef struct _DBPropertyAdapterPrivate DBPropertyAdapterPrivate;

#define DB_TYPE_TABLE_VIEW (db_table_view_get_type ())
#define DB_TABLE_VIEW(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), DB_TYPE_TABLE_VIEW, DBTableView))
#define DB_TABLE_VIEW_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), DB_TYPE_TABLE_VIEW, DBTableViewClass))
#define DB_IS_TABLE_VIEW(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), DB_TYPE_TABLE_VIEW))
#define DB_IS_TABLE_VIEW_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), DB_TYPE_TABLE_VIEW))
#define DB_TABLE_VIEW_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), DB_TYPE_TABLE_VIEW, DBTableViewClass))

typedef struct _DBTableView DBTableView;
typedef struct _DBTableViewClass DBTableViewClass;
typedef struct _DBTableViewPrivate DBTableViewPrivate;

#define DB_TYPE_VIEWABLE (db_viewable_get_type ())
#define DB_VIEWABLE(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), DB_TYPE_VIEWABLE, DBViewable))
#define DB_IS_VIEWABLE(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), DB_TYPE_VIEWABLE))
#define DB_VIEWABLE_GET_INTERFACE(obj) (G_TYPE_INSTANCE_GET_INTERFACE ((obj), DB_TYPE_VIEWABLE, DBViewableIface))

typedef struct _DBViewable DBViewable;
typedef struct _DBViewableIface DBViewableIface;

struct _DBPropertyAdapter {
	GObject parent_instance;
	DBPropertyAdapterPrivate * priv;
	gchar* val;
};

struct _DBPropertyAdapterClass {
	GObjectClass parent_class;
};

struct _DBTableView {
	GObject parent_instance;
	DBTableViewPrivate * priv;
	DBEntity* selected_entity;
	GtkTreeView* list_view;
	GtkListStore* list_store;
	GtkMenu* popup_menu;
};

struct _DBTableViewClass {
	GObjectClass parent_class;
	gchar** (*view_properties) (DBTableView* self, int* result_length1);
	GeeList* (*get_entity_list) (DBTableView* self);
	DBEntity* (*new_entity) (DBTableView* self);
	void (*remove_entity) (DBTableView* self, DBEntity* entity);
	void (*row_edited) (DBTableView* self, DBEntity* entity, const gchar* prop_name);
};

struct _DBViewableIface {
	GTypeInterface parent_iface;
	const gchar* (*get_display_name) (DBViewable* self);
};


GType db_property_adapter_get_type (void) G_GNUC_CONST;
DBPropertyAdapter* db_property_adapter_new (const gchar* _val);
DBPropertyAdapter* db_property_adapter_construct (GType object_type, const gchar* _val);
GType db_table_view_get_type (void) G_GNUC_CONST;
gchar** db_table_view_view_properties (DBTableView* self, int* result_length1);
GeeList* db_table_view_get_entity_list (DBTableView* self);
DBEntity* db_table_view_new_entity (DBTableView* self);
void db_table_view_remove_entity (DBTableView* self, DBEntity* entity);
DBEntity* db_table_view_get_selected_entity (DBTableView* self);
GtkWidget* db_table_view_get_root_widget (DBTableView* self);
void db_table_view_add_item_clicked (DBTableView* self);
void db_table_view_remove_item_clicked (DBTableView* self);
void db_table_view_update_view (DBTableView* self);
void db_table_view_refresh_row (DBTableView* self, DBEntity* entity);
DBTableView* db_table_view_construct (GType object_type);
DBDatabase* db_table_view_get_db (DBTableView* self);
void db_table_view_set_db (DBTableView* self, DBDatabase* value);
GType db_table_view_get_object_type (DBTableView* self);
void db_table_view_set_object_type (DBTableView* self, GType value);
gboolean db_table_view_get_view_only (DBTableView* self);
void db_table_view_set_view_only (DBTableView* self, gboolean value);
GType db_viewable_get_type (void) G_GNUC_CONST;
const gchar* db_viewable_get_display_name (DBViewable* self);


G_END_DECLS

#endif
