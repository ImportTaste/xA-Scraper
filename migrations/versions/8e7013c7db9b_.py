"""empty message

Revision ID: 8e7013c7db9b
Revises: 6ac11f48bcca
Create Date: 2017-12-10 19:46:02.777950

"""

# revision identifiers, used by Alembic.
revision = '8e7013c7db9b'
down_revision = '6ac11f48bcca'

from alembic import op
import sqlalchemy as sa
import json


def upgrade():
	# ### commands auto generated by Alembic - please adjust! ###
	conn = op.get_bind()
	pat_releases = conn.execute("SELECT id, release_meta FROM art_item WHERE artist_id IN (SELECT id FROM scrape_targets WHERE site_name='pat')")
	# print(list(pat_releases))

	for rid, postid in pat_releases:
		postid = int(postid)
		new_post = json.dumps({'type' : "post", 'id' : postid})
		changed = conn.execute("UPDATE art_item SET release_meta = %s WHERE id = %s", (new_post, rid))
		if changed.rowcount == 1:
			print(".", end="", flush=True)
		else:
			print("X", end="", flush=True)




def downgrade():
	# ### commands auto generated by Alembic - please adjust! ###
	pass
	# ### end Alembic commands ###