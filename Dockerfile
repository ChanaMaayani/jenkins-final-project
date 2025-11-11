FROM node:18-alpine
WORKDIR /app

# הוספת curl
RUN apk add --no-cache curl

COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
