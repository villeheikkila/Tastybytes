import { AuthChecker } from 'type-graphql';
import { getConnection } from 'typeorm';
import Account from '../entities/account.entity';

const authChecker: AuthChecker<{ state: { user: { id: string } } }> = async (
  { context },
  roles
): Promise<boolean> => {
  if (roles.includes('ADMIN')) {
    const account = await getConnection()
      .getRepository(Account)
      .findOne({
        where: { id: context.state.user.id },
        select: ['role']
      });

    return account?.role === 'ADMIN';
  }

  if ('state' in context) {
    return !!context.state.user;
  }

  return false;
};

export default authChecker;
