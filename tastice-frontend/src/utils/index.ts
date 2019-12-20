export const parseToken = (data: any): string | undefined => {
    try {
        const result = JSON.parse(data);
        return result.token;
    } catch {
        return undefined;
    }
};
