tolk 1.1

struct SimpleDao {
    yesVotes: uint32
    noVotes: uint32
    totalVotes: uint32
}

fun SimpleDao.load(): SimpleDao {
    return SimpleDao.fromCell(contract.getData());
}

fun SimpleDao.store(self) {
    contract.setData(self.toCell());
}

struct (0xF4A2B1C9) RecordVote {
    queryId: uint32
    vote: bool
}

struct (0xD4E7B328) ResetVotes {
    queryId: uint32
}

type MessageBody = RecordVote | ResetVotes

fun onInternalMessage(in: InMessage) {
    val msg = lazy MessageBody.fromSlice(in.body);

    match (msg) {
        RecordVote => {
            assert (msg.queryId > 0) throw 101;

            var dao = lazy SimpleDao.load();
            assert (dao.totalVotes < 4294967295) throw 102;

            if (msg.vote) {
                dao.yesVotes += 1;
            } else {
                dao.noVotes += 1;
            }

            dao.totalVotes += 1;
            dao.store();
        }
        ResetVotes => {
            assert (msg.queryId > 0) throw 103;

            var dao = lazy SimpleDao.load();
            dao.yesVotes = 0;
            dao.noVotes = 0;
            dao.totalVotes = 0;
            dao.store();
        }
        else => {
            assert (in.body.isEmpty()) throw 100;
        }
    }
}

get fun getVotes(): (uint32, uint32, uint32) {
    val dao = lazy SimpleDao.load();
    return (dao.yesVotes, dao.noVotes, dao.totalVotes);
}